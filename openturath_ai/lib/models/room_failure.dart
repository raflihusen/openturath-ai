import 'dart:math';

String newDiagnosticId() {
  final random = Random.secure();
  return List.generate(16, (_) => random.nextInt(256))
      .map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

/// Immutable cause captured before a controller or an error view disappears.
/// Contains no exception message, credentials, cookies, or account claims.
class RoomFailure {
  RoomFailure({required this.stage, required this.code, required this.agentId,
    required this.attemptId, this.reason, this.requestId, this.pageScheme,
    String? eventId}) : eventId = eventId ?? newDiagnosticId();

  final String stage;
  final String code;
  final String agentId;
  final String attemptId;
  final String eventId;
  final String? reason;
  final String? requestId;
  final String? pageScheme;

  static String safeIdentifier(String input) =>
      RegExp(r'^[a-zA-Z0-9_.:-]{1,80}$').hasMatch(input) ? input : 'unknown';

  Map<String, dynamic> get metadata => {
    'attempt_id': safeIdentifier(attemptId),
    'event_id': safeIdentifier(eventId),
    'agent_id': safeIdentifier(agentId),
    if (reason != null) 'reason': safeIdentifier(reason!),
    if (requestId != null) 'request_id': safeIdentifier(requestId!),
    if (pageScheme != null) 'page_scheme': safeIdentifier(pageScheme!),
  };
}
