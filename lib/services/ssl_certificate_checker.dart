import 'dart:async';
import 'dart:io';

class SslCheckResult {
  final DateTime? expiryDate;
  final String? error;
  const SslCheckResult({this.expiryDate, this.error});

  bool get succeeded => error == null && expiryDate != null;
}

/// Checks a monitored HTTPS host's certificate expiry directly — no
/// dependency on UptimeRobot's API (their SSL monitoring is a paid-plan
/// feature; this talks straight to the target host).
class SslCertificateChecker {
  static const _timeout = Duration(seconds: 10);

  /// [url] must be an "https://" URL. Connects to host:443 (or the URL's
  /// own port), accepting any certificate — including expired/self-signed
  /// ones — so the actual expiry can still be read rather than the
  /// connection failing on the very thing being checked.
  Future<SslCheckResult> check(String url) async {
    final Uri uri;
    try {
      uri = Uri.parse(url);
    } catch (e) {
      return SslCheckResult(error: 'Invalid URL: $e');
    }
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      return const SslCheckResult(error: 'Not an https:// URL');
    }
    final port = uri.hasPort ? uri.port : 443;

    X509Certificate? certificate;
    SecureSocket? socket;
    try {
      socket = await SecureSocket.connect(
        uri.host,
        port,
        onBadCertificate: (cert) {
          certificate = cert;
          return true; // Accept anything — we're inspecting, not trusting.
        },
        timeout: _timeout,
      );
      // A fully valid, trusted cert never reaches onBadCertificate, so
      // read it here too.
      certificate ??= socket.peerCertificate;
    } catch (e) {
      return SslCheckResult(error: e.toString());
    } finally {
      unawaited(socket?.close());
    }

    if (certificate == null) {
      return const SslCheckResult(error: 'No certificate presented');
    }
    return SslCheckResult(expiryDate: certificate!.endValidity);
  }
}
