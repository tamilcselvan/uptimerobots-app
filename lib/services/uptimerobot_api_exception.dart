class UptimeRobotApiException implements Exception {
  final String message;
  const UptimeRobotApiException(this.message);

  @override
  String toString() => message;
}
