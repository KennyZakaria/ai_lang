// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pronunciation_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PronunciationScore _$PronunciationScoreFromJson(Map<String, dynamic> json) =>
    PronunciationScore(
      accuracy: (json['accuracy'] as num).toDouble(),
      fluency: (json['fluency'] as num).toDouble(),
      completeness: (json['completeness'] as num).toDouble(),
      overall: (json['overall'] as num).toDouble(),
      feedback: json['feedback'] as String,
    );

Map<String, dynamic> _$PronunciationScoreToJson(PronunciationScore instance) =>
    <String, dynamic>{
      'accuracy': instance.accuracy,
      'fluency': instance.fluency,
      'completeness': instance.completeness,
      'overall': instance.overall,
      'feedback': instance.feedback,
    };

PracticeResponse _$PracticeResponseFromJson(Map<String, dynamic> json) =>
    PracticeResponse(
      transcribedText: json['transcribedText'] as String,
      expectedText: json['expectedText'] as String,
      pronunciationScore: PronunciationScore.fromJson(
          json['pronunciationScore'] as Map<String, dynamic>),
      isCorrect: json['isCorrect'] as bool,
      encouragement: json['encouragement'] as String,
      nextExerciseId: json['nextExerciseId'] as String?,
    );

Map<String, dynamic> _$PracticeResponseToJson(PracticeResponse instance) =>
    <String, dynamic>{
      'transcribedText': instance.transcribedText,
      'expectedText': instance.expectedText,
      'pronunciationScore': instance.pronunciationScore.toJson(),
      'isCorrect': instance.isCorrect,
      'encouragement': instance.encouragement,
      'nextExerciseId': instance.nextExerciseId,
    };
