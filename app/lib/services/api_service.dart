import 'dart:io';import 'dart:io';import 'dart:io';

import 'package:dio/dio.dart';

import '../models/course.dart';import 'dart:convert';import 'package:dio/dio.dart';

import '../models/pronunciation_score.dart';

import 'package:dio/dio.dart';import '../models/transcript_response.dart';

class ApiService {

  late final Dio _dio;import '../models/course.dart';import '../models/chat_response.dart';

  final String baseUrl;

import '../models/pronunciation_score.dart';

  ApiService({required this.baseUrl}) {

    _dio = Dio(BaseOptions(class NatulangApiService {

      baseUrl: baseUrl,

      connectTimeout: const Duration(seconds: 30),class ApiService {  final Dio _dio;

      receiveTimeout: const Duration(seconds: 30),

    ));  late final Dio _dio;  String? _sessionId;

  }

  final String baseUrl;

  // === Course APIs ===

  NatulangApiService({String baseUrl = 'http://localhost:8000'})

  Future<List<Course>> getCourses() async {

    try {  ApiService({required this.baseUrl}) {      : _dio = Dio(BaseOptions(

      final response = await _dio.get('/api/courses');

      final List courses = response.data as List<dynamic>;    _dio = Dio(BaseOptions(          baseUrl: baseUrl,

      return courses.map((c) => Course.fromJson(c)).toList();

    } catch (e) {      baseUrl: baseUrl,          connectTimeout: const Duration(seconds: 30),

      throw _handleError(e);

    }      connectTimeout: const Duration(seconds: 30),          receiveTimeout: const Duration(seconds: 30),

  }

      receiveTimeout: const Duration(seconds: 30),        ));

  Future<Course> getCourse(String courseId) async {

    try {      headers: {

      final response = await _dio.get('/api/courses/$courseId');

      return Course.fromJson(response.data);        'Content-Type': 'application/json',  String? get sessionId => _sessionId;

    } catch (e) {

      throw _handleError(e);      },

    }

  }    ));  Future<void> createSession() async {



  Future<List<Lesson>> getCourseLessons(String courseId) async {  }    try {

    try {

      final response = await _dio.get('/api/courses/$courseId/lessons');      final response = await _dio.post('/session');

      final List lessons = response.data as List<dynamic>;

      return lessons.map((l) => Lesson.fromJson(l)).toList();  // === Course APIs ===      _sessionId = response.data['sessionId'];

    } catch (e) {

      throw _handleError(e);    } on DioException catch (e) {

    }

  }  Future<List<Course>> getCourses() async {      throw ApiException('Failed to create session: ${e.message}');



  Future<Lesson> getLesson(String lessonId) async {    try {    }

    try {

      final response = await _dio.get('/api/lessons/$lessonId');      final response = await _dio.get('/api/courses');  }

      return Lesson.fromJson(response.data);

    } catch (e) {      final List courses = response.data as List<dynamic>;

      throw _handleError(e);

    }      return courses.map((c) => Course.fromJson(c)).toList();  Future<TranscriptResponse> transcribe({

  }

    } catch (e) {    required File audioFile,

  // === Practice API ===

      throw _handleError(e);    String languageCode = 'en',

  Future<PracticeResponse> submitPractice({

    required File audioFile,    }  }) async {

    required String lessonId,

    required String exerciseId,  }    try {

    required String expectedText,

    String userId = 'default-user',      final formData = FormData.fromMap({

    String languageCode = 'fr',

  }) async {  Future<Course> getCourse(String courseId) async {        'file': await MultipartFile.fromFile(

    try {

      final formData = FormData.fromMap({    try {          audioFile.path,

        'file': await MultipartFile.fromFile(

          audioFile.path,      final response = await _dio.get('/api/courses/$courseId');          filename: 'audio.wav',

          filename: 'audio.wav',

        ),      return Course.fromJson(response.data);        ),

        'lessonId': lessonId,

        'exerciseId': exerciseId,    } catch (e) {        'languageCode': languageCode,

        'expectedText': expectedText,

        'userId': userId,      throw _handleError(e);      });

        'languageCode': languageCode,

      });    }



      final response = await _dio.post('/api/practice', data: formData);  }      final response = await _dio.post('/stt', data: formData);

      return PracticeResponse.fromJson(response.data);

    } catch (e) {      return TranscriptResponse.fromJson(response.data);

      throw _handleError(e);

    }  Future<List<Lesson>> getCourseLessons(String courseId) async {    } on DioException catch (e) {

  }

    try {      throw ApiException('Transcription failed: ${e.message}');

  // === TTS API ===

      final response = await _dio.get('/api/courses/$courseId/lessons');    }

  Future<String?> synthesizeSpeech({

    required String text,      final List lessons = response.data as List<dynamic>;  }

    String languageCode = 'fr',

    String? voice,      return lessons.map((l) => Lesson.fromJson(l)).toList();

  }) async {

    try {    } catch (e) {  Future<ChatResponse> chat({

      final response = await _dio.post('/api/tts', data: {

        'text': text,      throw _handleError(e);    required String transcript,

        'languageCode': languageCode,

        'voice': voice,    }    required String targetLanguage,

      });

  }    String? proficiencyLevel,

      return response.data['audioBase64'] as String?;

    } catch (e) {  }) async {

      throw _handleError(e);

    }  Future<Lesson> getLesson(String lessonId) async {    if (_sessionId == null) {

  }

    try {      await createSession();

  // === Progress API ===

      final response = await _dio.get('/api/lessons/$lessonId');    }

  Future<Map<String, dynamic>> getUserProgress(String userId) async {

    try {      return Lesson.fromJson(response.data);

      final response = await _dio.get('/api/progress/$userId');

      return response.data;    } catch (e) {    try {

    } catch (e) {

      throw _handleError(e);      throw _handleError(e);      final response = await _dio.post('/chat', data: {

    }

  }    }        'transcript': transcript,



  Future<Map<String, dynamic>> getCourseProgress(String userId, String courseId) async {  }        'sessionId': _sessionId,

    try {

      final response = await _dio.get('/api/progress/$userId/course/$courseId');        'targetLanguage': targetLanguage,

      return response.data;

    } catch (e) {  // === Practice API ===        'proficiencyLevel': proficiencyLevel,

      throw _handleError(e);

    }      });

  }

  Future<PracticeResponse> submitPractice({

  // === Health Check ===

    required File audioFile,      return ChatResponse.fromJson(response.data);

  Future<bool> checkHealth() async {

    try {    required String lessonId,    } on DioException catch (e) {

      final response = await _dio.get('/health');

      return response.data['status'] == 'ok';    required String exerciseId,      throw ApiException('Chat request failed: ${e.message}');

    } catch (_) {

      return false;    required String expectedText,    }

    }

  }    String userId = 'default-user',  }



  // === Error Handling ===    String languageCode = 'fr',



  Exception _handleError(dynamic error) {  }) async {  Future<String> textToSpeech({

    if (error is DioException) {

      switch (error.type) {    try {    required String text,

        case DioExceptionType.connectionTimeout:

        case DioExceptionType.receiveTimeout:      final formData = FormData.fromMap({    String? voice,

          return Exception('Connection timeout. Please check your network.');

        case DioExceptionType.badResponse:        'file': await MultipartFile.fromFile(    String? languageCode,

          final statusCode = error.response?.statusCode;

          final message = error.response?.data['detail'] ?? 'Server error';          audioFile.path,  }) async {

          return Exception('Error $statusCode: $message');

        default:          filename: 'audio.wav',    try {

          return Exception('Network error. Please try again.');

      }        ),      final response = await _dio.post('/tts', data: {

    }

    return Exception('An unexpected error occurred: $error');        'lessonId': lessonId,        'text': text,

  }

}        'exerciseId': exerciseId,        'voice': voice,


        'expectedText': expectedText,        'languageCode': languageCode,

        'userId': userId,      });

        'languageCode': languageCode,

      });      return response.data['audioBase64'] ?? '';

    } on DioException catch (e) {

      final response = await _dio.post('/api/practice', data: formData);      throw ApiException('TTS request failed: ${e.message}');

      return PracticeResponse.fromJson(response.data);    }

    } catch (e) {  }

      throw _handleError(e);

    }  Future<bool> checkHealth() async {

  }    try {

      final response = await _dio.get('/health');

  // === TTS API ===      return response.data['status'] == 'ok';

    } catch (_) {

  Future<String?> synthesizeSpeech({      return false;

    required String text,    }

    String languageCode = 'fr',  }

    String? voice,}

  }) async {

    try {class ApiException implements Exception {

      final response = await _dio.post('/api/tts', data: {  final String message;

        'text': text,  ApiException(this.message);

        'languageCode': languageCode,

        'voice': voice,  @override

      });  String toString() => message;

      }

      return response.data['audioBase64'] as String?;
    } catch (e) {
      throw _handleError(e);
    }
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
