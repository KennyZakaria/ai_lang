import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import '../models/chat_turn.dart';
import '../models/correction.dart';
import '../services/api_service.dart';

enum ConversationState { idle, recording, transcribing, thinking, speaking }

class ConversationProvider extends ChangeNotifier {
  final NatulangApiService _api;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  ConversationState _state = ConversationState.idle;
  String _transcript = '';
  final List<ChatTurn> _turns = [];
  String? _errorMessage;
  String _targetLanguage = 'English';
  String? _proficiencyLevel;

  ConversationProvider({String apiBaseUrl = 'http://localhost:8000'})
      : _api = NatulangApiService(baseUrl: apiBaseUrl) {
    _initialize();
  }

  // Getters
  ConversationState get state => _state;
  String get transcript => _transcript;
  List<ChatTurn> get turns => List.unmodifiable(_turns);
  String? get error => _errorMessage;
  String get targetLanguage => _targetLanguage;
  bool get isRecording => _state == ConversationState.recording;
  bool get isProcessing =>
      _state == ConversationState.transcribing ||
      _state == ConversationState.thinking;

  void _setState(ConversationState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(ConversationState.idle);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _initialize() async {
    try {
      final healthy = await _api.checkHealth();
      if (!healthy) {
        _setError('Backend server is not responding');
      }
    } catch (e) {
      _setError('Could not connect to server: $e');
    }
  }

  void setTargetLanguage(String language) {
    _targetLanguage = language;
    notifyListeners();
  }

  void setProficiencyLevel(String? level) {
    _proficiencyLevel = level;
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    if (_state == ConversationState.recording) {
      await _stopRecording();
    } else if (_state == ConversationState.idle) {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        _setError('Microphone permission denied');
        return;
      }

      final path = '${Directory.systemTemp.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );
      
      _setState(ConversationState.recording);
      _transcript = '';
      clearError();
    } catch (e) {
      _setError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      _setState(ConversationState.transcribing);

      if (path != null) {
        await _processRecording(File(path));
      } else {
        _setError('No recording path returned');
      }
    } catch (e) {
      _setError('Failed to stop recording: $e');
    }
  }

  Future<void> _processRecording(File audioFile) async {
    try {
      // Transcribe
      final transcriptResponse = await _api.transcribe(
        audioFile: audioFile,
        languageCode: _getLanguageCode(_targetLanguage),
      );

      _transcript = transcriptResponse.text;
      notifyListeners();

      if (_transcript.isEmpty) {
        _setError('No speech detected');
        return;
      }

      // Get AI response
      _setState(ConversationState.thinking);
      final chatResponse = await _api.chat(
        transcript: _transcript,
        targetLanguage: _targetLanguage,
        proficiencyLevel: _proficiencyLevel,
      );

      final turn = ChatTurn(
        user: _transcript,
        ai: chatResponse.reply,
        corrections: chatResponse.corrections,
        suggestions: chatResponse.suggestions,
      );

      _turns.add(turn);
      notifyListeners();

      // Synthesize and play
      await _speakResponse(chatResponse.reply);
    } catch (e) {
      _setError('Processing error: $e');
    } finally {
      // Clean up temp file
      try {
        await audioFile.delete();
      } catch (_) {}
    }
  }

  Future<void> _speakResponse(String text) async {
    try {
      _setState(ConversationState.speaking);
      
      final audioBase64 = await _api.textToSpeech(
        text: text,
        languageCode: _getLanguageCode(_targetLanguage),
      );

      if (audioBase64.isNotEmpty) {
        final bytes = base64Decode(audioBase64);
        final source = AudioSource.fromBytes(bytes, tag: 'tts');
        await _player.setAudioSource(source);
        await _player.play();
        
        // Wait for playback to finish
        await _player.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        );
      }
    } catch (e) {
      // TTS failure is non-critical, just log
      debugPrint('TTS failed: $e');
    } finally {
      _setState(ConversationState.idle);
    }
  }

  String _getLanguageCode(String language) {
    final codes = {
      'English': 'en',
      'Spanish': 'es',
      'French': 'fr',
      'German': 'de',
      'Italian': 'it',
      'Portuguese': 'pt',
      'Japanese': 'ja',
      'Chinese': 'zh',
      'Korean': 'ko',
      'Arabic': 'ar',
    };
    return codes[language] ?? 'en';
  }

  void clearConversation() {
    _turns.clear();
    _transcript = '';
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
