import 'dart:io';
import 'package:dio/dio.dart';
import '../models/course.dart';
import '../models/pronunciation_score.dart';
import '../models/transcript_response.dart';
import '../models/chat_response.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;

  ApiService({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  // === Course APIs ===

  Future<List<Course>> getCourses() async {
    try {
      print('📡 Fetching courses from $baseUrl/api/courses');
      final response = await _dio.get('/api/courses');
      print('✅ Courses response: ${response.data}');
      final List courses = response.data as List<dynamic>;
      return courses.map((c) => Course.fromJson(c)).toList();
    } catch (e) {
      print('❌ Error fetching courses: $e');
      throw _handleError(e);
    }
  }

  Future<Course> getCourse(String courseId) async {
    try {
      final response = await _dio.get('/api/courses/$courseId');
      return Course.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Lesson>> getCourseLessons(String courseId) async {
    try {
      final response = await _dio.get('/api/courses/$courseId/lessons');
      final List lessons = response.data as List<dynamic>;
      return lessons.map((l) => Lesson.fromJson(l)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Lesson> getLesson(String lessonId) async {
    try {
      final response = await _dio.get('/api/lessons/$lessonId');
      return Lesson.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // === Practice API ===

  Future<PracticeResponse> submitPractice({
    required File audioFile,
    required String lessonId,
    required String exerciseId,
    required String expectedText,
    String userId = 'default-user',
    String languageCode = 'fr',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'audio.wav',
        ),
        'lessonId': lessonId,
        'exerciseId': exerciseId,
        'expectedText': expectedText,
        'userId': userId,
        'languageCode': languageCode,
      });

      final response = await _dio.post('/api/practice', data: formData);
      return PracticeResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // === TTS API ===

  Future<String?> synthesizeSpeech({
    required String text,
    String languageCode = 'fr',
    String? voice,
  }) async {
    try {
      final response = await _dio.post('/api/tts', data: {
        'text': text,
        'languageCode': languageCode,
        'voice': voice,
      });

      return response.data['audioBase64'] as String?;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Compatibility methods used by ConversationProvider
  Future<TranscriptResponse> transcribe({
    required File audioFile,
    String languageCode = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioFile.path, filename: 'audio.wav'),
        'languageCode': languageCode,
      });

      final response = await _dio.post('/stt', data: formData);
      return TranscriptResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ChatResponse> chat({
    required String transcript,
    required String targetLanguage,
    String? proficiencyLevel,
    String? sessionId,
  }) async {
    try {
      final response = await _dio.post('/chat', data: {
        'transcript': transcript,
        'targetLanguage': targetLanguage,
        'proficiencyLevel': proficiencyLevel,
        'sessionId': sessionId,
      });
      return ChatResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> textToSpeech({
    required String text,
    String languageCode = 'en',
  }) async {
    final maybe = await synthesizeSpeech(text: text, languageCode: languageCode);
    return maybe ?? '';
  }

  // === Progress API ===

  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      final response = await _dio.get('/api/progress/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCourseProgress(String userId, String courseId) async {
    try {
      final response = await _dio.get('/api/progress/$userId/course/$courseId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // === Health Check ===

  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  // === Error Handling ===

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your network.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data['detail'] ?? 'Server error';
          return Exception('Error $statusCode: $message');
        default:
          return Exception('Network error. Please try again.');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}
