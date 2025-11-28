import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Course> _courses = [];
  List<Lesson> _currentLessons = [];
  Course? _selectedCourse;
  Lesson? _selectedLesson;
  bool _isLoading = false;
  String? _error;

  CourseProvider(this._apiService);

  // Getters
  List<Course> get courses => _courses;
  List<Lesson> get currentLessons => _currentLessons;
  Course? get selectedCourse => _selectedCourse;
  Lesson? get selectedLesson => _selectedLesson;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all courses
  Future<void> loadCourses() async {
    print('🔄 Loading courses...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _apiService.getCourses();
      print('✅ Loaded ${_courses.length} courses');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading courses: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a course and load its lessons
  Future<void> selectCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCourse = await _apiService.getCourse(courseId);
      _currentLessons = await _apiService.getCourseLessons(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a lesson
  Future<void> selectLesson(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedLesson = await _apiService.getLesson(lessonId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
