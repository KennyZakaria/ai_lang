import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import '../models/course.dart';
import '../models/pronunciation_score.dart';
import '../services/api_service.dart';
import 'dart:convert';

enum PracticeState {
  idle,
  playingFrench,
  recording,
  submitting,
  showingResults,
}

class PracticeProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  Lesson? _currentLesson;
  int _currentExerciseIndex = 0;
  PracticeState _state = PracticeState.idle;
  PracticeResponse? _lastResponse;
  String? _error;
  String? _recordedFilePath;

  PracticeProvider(this._apiService);

  // Getters
  Lesson? get currentLesson => _currentLesson;
  Exercise? get currentExercise =>
      _currentLesson != null && _currentExerciseIndex < _currentLesson!.exercises.length
          ? _currentLesson!.exercises[_currentExerciseIndex]
          : null;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get totalExercises => _currentLesson?.exercises.length ?? 0;
  PracticeState get state => _state;
  PracticeResponse? get lastResponse => _lastResponse;
  String? get error => _error;
  bool get isRecording => _state == PracticeState.recording;
  bool get canRecord => _state == PracticeState.idle;

  // Start a practice session with a lesson
  void startLesson(Lesson lesson) {
    _currentLesson = lesson;
    _currentExerciseIndex = 0;
    _state = PracticeState.idle;
    _lastResponse = null;
    _error = null;
    notifyListeners();
  }

  // Play French audio using TTS
  Future<void> playFrenchAudio() async {
    if (currentExercise == null) return;

    _state = PracticeState.playingFrench;
    _error = null;
    notifyListeners();

    try {
      final base64Audio = await _apiService.synthesizeSpeech(
        text: currentExercise!.phrase.target,
        languageCode: 'fr',
      );

      if (base64Audio != null && base64Audio.isNotEmpty) {
        final bytes = base64Decode(base64Audio);
        
        // Save to temp file and play
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(bytes);
        
        await _player.setFilePath(audioFile.path);
        await _player.play();
        
        // Wait for playback to finish
        await _player.playerStateStream.firstWhere((state) => state.processingState == ProcessingState.completed);
        
        // Clean up
        await audioFile.delete();
      }

      _state = PracticeState.idle;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to play audio: $e';
      _state = PracticeState.idle;
      notifyListeners();
    }
  }

  // Start recording
  Future<void> startRecording() async {
    if (!canRecord) return;

    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordedFilePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _recordedFilePath!,
        );
        
        _state = PracticeState.recording;
        _error = null;
        notifyListeners();
      } else {
        _error = 'Microphone permission denied';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  // Stop recording and submit
  Future<void> stopRecordingAndSubmit() async {
    if (_state != PracticeState.recording) return;

    try {
      await _recorder.stop();
      
      if (_recordedFilePath == null) {
        _error = 'No recording found';
        _state = PracticeState.idle;
        notifyListeners();
        return;
      }

      _state = PracticeState.submitting;
      notifyListeners();

      final audioFile = File(_recordedFilePath!);
      final exercise = currentExercise!;

      final response = await _apiService.submitPractice(
        audioFile: audioFile,
        lessonId: _currentLesson!.id,
        exerciseId: exercise.id,
        expectedText: exercise.phrase.target,
        languageCode: 'fr',
      );

      _lastResponse = response;
      _state = PracticeState.showingResults;
      
      // Clean up recording file
      await audioFile.delete();
      _recordedFilePath = null;
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to submit: $e';
      _state = PracticeState.idle;
      notifyListeners();
    }
  }

  // Move to next exercise
  void nextExercise() {
    if (_currentLesson == null) return;

    if (_currentExerciseIndex < _currentLesson!.exercises.length - 1) {
      _currentExerciseIndex++;
      _state = PracticeState.idle;
      _lastResponse = null;
      _error = null;
      notifyListeners();
    }
  }

  // Retry current exercise
  void retryExercise() {
    _state = PracticeState.idle;
    _lastResponse = null;
    _error = null;
    notifyListeners();
  }

  // Check if lesson is complete
  bool get isLessonComplete =>
      _lastResponse != null &&
      _currentExerciseIndex >= totalExercises - 1 &&
      _lastResponse!.isCorrect;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
