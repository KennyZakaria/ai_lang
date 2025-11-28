import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final String id;
  final String title;
  final String description;
  final String targetLanguage;
  final String difficulty;
  final String topicCategory;
  final int lessonsCount;
  final String? imageUrl;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.targetLanguage,
    required this.difficulty,
    required this.topicCategory,
    required this.lessonsCount,
    this.imageUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@JsonSerializable()
class Phrase {
  final String id;
  final String english;
  final String target;
  final String? phonetic;
  final String? audioUrl;

  Phrase({
    required this.id,
    required this.english,
    required this.target,
    this.phonetic,
    this.audioUrl,
  });

  factory Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);
  Map<String, dynamic> toJson() => _$PhraseToJson(this);
}

@JsonSerializable()
class Exercise {
  final String id;
  final String type;
  final Phrase phrase;
  final List<String> hints;

  Exercise({
    required this.id,
    required this.type,
    required this.phrase,
    required this.hints,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable()
class Lesson {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final List<Exercise> exercises;
  final int order;
  final int estimatedMinutes;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.exercises,
    required this.order,
    required this.estimatedMinutes,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
