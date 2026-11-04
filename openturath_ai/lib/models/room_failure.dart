import 'dart:math';

String newDiagnosticId() {
  final random = Random.secure();
  return List.generate(16, (_) => random.nextInt(256))
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}

/// Immutable cause captured before a controller or an error view disappears.
/// Contains no exception message, credentials, cookies, or account claims.
class RoomFailure {
  RoomFailure(
      {required this.stage,
      required this.code,
      required this.agentId,
      required this.attemptId,
      this.reason,
      this.requestId,
      this.pageScheme,
      String? eventId})
      : eventId = eventId ?? newDiagnosticId();

  final String stage;
  final String code;
  final String agentId;
  final String attemptId;
  final String eventId;
  final String? reason;
  final String? requestId;
  final String? pageScheme;

  static String _safe(String value, String pattern) =>
      RegExp(pattern).hasMatch(value) ? value : 'unknown';

  Map<String, dynamic> get metadata => {
        'attempt_id': _safe(attemptId, r'^[a-f0-9]{32}$'),
        'event_id': _safe(eventId, r'^[a-f0-9]{32}$'),
        'agent_id': _safe(agentId, r'^[a-zA-Z0-9_-]{1,80}$'),
        if (reason != null) 'reason': _safe(reason!, r'^[a-z][a-z0-9_]{0,59}$'),
        if (requestId != null)
          'request_id': _safe(requestId!,
              r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'),
        if (pageScheme != null)
          'page_scheme': _safe(pageScheme!, r'^[a-z][a-z0-9+-]{0,31}$'),
      };
}
