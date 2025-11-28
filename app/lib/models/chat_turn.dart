import 'correction.dart';

class ChatTurn {
  final String user;
  final String ai;
  final List<Correction> corrections;
  final List<String> suggestions;
  final DateTime timestamp;

  ChatTurn({
    required this.user,
    required this.ai,
    this.corrections = const [],
    this.suggestions = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
