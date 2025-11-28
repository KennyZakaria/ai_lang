// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetLanguage: json['targetLanguage'] as String,
      difficulty: json['difficulty'] as String,
      topicCategory: json['topicCategory'] as String,
      lessonsCount: (json['lessonsCount'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'targetLanguage': instance.targetLanguage,
      'difficulty': instance.difficulty,
      'topicCategory': instance.topicCategory,
      'lessonsCount': instance.lessonsCount,
      'imageUrl': instance.imageUrl,
    };

Phrase _$PhraseFromJson(Map<String, dynamic> json) => Phrase(
      id: json['id'] as String,
      english: json['english'] as String,
      target: json['target'] as String,
      phonetic: json['phonetic'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );

Map<String, dynamic> _$PhraseToJson(Phrase instance) => <String, dynamic>{
      'id': instance.id,
      'english': instance.english,
      'target': instance.target,
      'phonetic': instance.phonetic,
      'audioUrl': instance.audioUrl,
    };

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      type: json['type'] as String,
      phrase: Phrase.fromJson(json['phrase'] as Map<String, dynamic>),
      hints: (json['hints'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'phrase': instance.phrase.toJson(),
      'hints': instance.hints,
    };

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      courseId: json['courseId'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: (json['order'] as num).toInt(),
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'courseId': instance.courseId,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'order': instance.order,
      'estimatedMinutes': instance.estimatedMinutes,
    };
