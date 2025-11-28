import 'package:json_annotation/json_annotation.dart';

part 'transcript_response.g.dart';

@JsonSerializable()
class TranscriptResponse {
  final String text;
  final double confidence;
  final String provider;

  TranscriptResponse({
    required this.text,
    this.confidence = 0.0,
    this.provider = 'stub',
  });

  factory TranscriptResponse.fromJson(Map<String, dynamic> json) =>
      _$TranscriptResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TranscriptResponseToJson(this);
}
