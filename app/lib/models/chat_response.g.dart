// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
      reply: json['reply'] as String,
      corrections: (json['corrections'] as List<dynamic>?)
              ?.map((e) => Correction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nextPrompt: json['nextPrompt'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'reply': instance.reply,
      'corrections': instance.corrections.map((e) => e.toJson()).toList(),
      'suggestions': instance.suggestions,
      'nextPrompt': instance.nextPrompt,
      'meta': instance.meta,
    };
