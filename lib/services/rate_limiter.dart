import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Guards one UptimeRobot api_key against 429s:
/// - Spaces consecutive calls at least [minGap] apart (defensive, since the
///   free tier is documented as ~10 requests/minute per key).
/// - Retries on HTTP 429 with exponential backoff, honoring `Retry-After`
///   when the API sends one.
class RateLimiter {
  static const _maxRetries = 3;

  final Duration minGap;
  DateTime? _lastCallAt;

  RateLimiter({this.minGap = const Duration(milliseconds: 1200)});

  static final Map<String, RateLimiter> _perKey = {};

  /// One limiter per api_key, shared across API client instances, so
  /// throttling state survives even though a fresh client is created
  /// for every sync pass.
  factory RateLimiter.forApiKey(String apiKey) =>
      _perKey.putIfAbsent(apiKey, RateLimiter.new);

  /// Frees limiter for [apiKey] when account removed — prevents static
  /// map growing unbounded across add/remove cycles.
  static void removeForApiKey(String apiKey) => _perKey.remove(apiKey);

  Future<T> run<T>(Future<T> Function() call) async {
    await _waitForSlot();

    var attempt = 0;
    while (true) {
      try {
        final result = await call();
        _lastCallAt = DateTime.now();
        return result;
      } on DioException catch (e) {
        _lastCallAt = DateTime.now();
        final status = e.response?.statusCode;
        if (status != 429 || attempt >= _maxRetries) rethrow;

        attempt++;
        await Future.delayed(_backoffDelay(attempt, e));
      }
    }
  }

  Future<void> _waitForSlot() async {
    final last = _lastCallAt;
    if (last == null) return;
    final elapsed = DateTime.now().difference(last);
    if (elapsed < minGap) {
      await Future.delayed(minGap - elapsed);
    }
  }

  Duration _backoffDelay(int attempt, DioException e) {
    final retryAfterHeader = e.response?.headers.value('retry-after');
    final retryAfterSeconds = retryAfterHeader != null
        ? int.tryParse(retryAfterHeader)
        : null;
    if (retryAfterSeconds != null) {
      return Duration(seconds: retryAfterSeconds);
    }
    // Exponential backoff with jitter: 1s, 2s, 4s (+ up to 300ms jitter).
    final baseMs = 1000 * pow(2, attempt - 1).toInt();
    final jitterMs = Random().nextInt(300);
    return Duration(milliseconds: baseMs + jitterMs);
  }
}
