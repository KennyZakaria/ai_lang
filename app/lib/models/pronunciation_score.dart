import 'package:json_annotation/json_annotation.dart';

part 'pronunciation_score.g.dart';

@JsonSerializable()
class PronunciationScore {
  final double accuracy;
  final double fluency;
  final double completeness;
  final double overall;
  final String feedback;

  PronunciationScore({
    required this.accuracy,
    required this.fluency,
    required this.completeness,
    required this.overall,
    required this.feedback,
  });

  factory PronunciationScore.fromJson(Map<String, dynamic> json) =>
      _$PronunciationScoreFromJson(json);
  Map<String, dynamic> toJson() => _$PronunciationScoreToJson(this);
}

@JsonSerializable()
class PracticeResponse {
  final String transcribedText;
  final String expectedText;
  final PronunciationScore pronunciationScore;
  final bool isCorrect;
  final String encouragement;
  final String? nextExerciseId;

  PracticeResponse({
    required this.transcribedText,
    required this.expectedText,
    required this.pronunciationScore,
    required this.isCorrect,
    required this.encouragement,
    this.nextExerciseId,
  });

  factory PracticeResponse.fromJson(Map<String, dynamic> json) =>
      _$PracticeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PracticeResponseToJson(this);
}
