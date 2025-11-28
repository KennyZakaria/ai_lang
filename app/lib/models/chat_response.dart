import 'package:json_annotation/json_annotation.dart';
import 'correction.dart';

part 'chat_response.g.dart';

@JsonSerializable()
class ChatResponse {
  final String reply;
  final List<Correction> corrections;
  final List<String> suggestions;
  final String? nextPrompt;
  final Map<String, dynamic>? meta;

  ChatResponse({
    required this.reply,
    this.corrections = const [],
    this.suggestions = const [],
    this.nextPrompt,
    this.meta,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}
