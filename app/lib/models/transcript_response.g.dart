// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscriptResponse _$TranscriptResponseFromJson(Map<String, dynamic> json) =>
    TranscriptResponse(
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      provider: json['provider'] as String? ?? 'stub',
    );

Map<String, dynamic> _$TranscriptResponseToJson(TranscriptResponse instance) =>
    <String, dynamic>{
      'text': instance.text,
      'confidence': instance.confidence,
      'provider': instance.provider,
    };
