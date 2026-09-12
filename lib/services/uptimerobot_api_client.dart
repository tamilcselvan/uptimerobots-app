import 'package:dio/dio.dart';

import '../models/account_summary.dart';
import '../models/monitor.dart';
import 'rate_limiter.dart';
import 'uptimerobot_api_exception.dart';

/// Thin client for one UptimeRobot account (one api_key).
/// API docs: https://uptimerobot.com/api/
class UptimeRobotApiClient {
  static const _baseUrl = 'https://api.uptimerobot.com/v2';

  final String apiKey;
  final Dio _dio;
  final RateLimiter _rateLimiter;

  UptimeRobotApiClient(this.apiKey, {Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: _baseUrl,
          contentType: Headers.formUrlEncodedContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )),
        _rateLimiter = RateLimiter.forApiKey(apiKey);

  Future<Map<String, dynamic>> _post(String path, [Map<String, dynamic>? extra]) {
    return _rateLimiter.run(() => _postOnce(path, extra));
  }

  Future<Map<String, dynamic>> _postOnce(String path, Map<String, dynamic>? extra) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: {
        'api_key': apiKey,
        'format': 'json',
        ...?extra,
      },
    );
    final data = response.data;
    if (data == null) {
      throw const UptimeRobotApiException('Empty response from UptimeRobot');
    }
    if (data['stat'] == 'fail') {
      final error = data['error'] as Map<String, dynamic>?;
      throw UptimeRobotApiException(error?['message'] as String? ?? 'Unknown UptimeRobot API error');
    }
    return data;
  }

  /// Validates the key and returns account-level stats.
  Future<AccountSummary> getAccountDetails() async {
    final json = await _post('/getAccountDetails');
    return AccountSummary.fromJson(json);
  }

  Future<List<MonitorApiData>> getMonitors() async {
    final json = await _post('/getMonitors', {
      'response_times': '1',
      'response_times_limit': '1',
      'all_time_uptime_ratio': '1',
      'logs': '0',
    });
    final monitors = json['monitors'] as List<dynamic>? ?? [];
    return monitors
        .cast<Map<String, dynamic>>()
        .map(MonitorApiData.fromJson)
        .toList();
  }
}
