# Natulang Implementation Plan

## Overview
Transform the app into a Natulang-style course-based language learning system with:
- Structured courses organized by topics (greetings, travel, business, etc.)
- Lessons containing French-English phrase pairs
- Speech-first practice: listen → repeat → get pronunciation feedback
- Spaced repetition and progress tracking

---

## Phase 1: Backend Core Structure ✅ IN PROGRESS

### 1.1 Data Models ✅ DONE
- [x] Course, Lesson, Exercise, Phrase models
- [x] PronunciationScore, PracticeRequest/Response
- [x] UserProgress tracking model

### 1.2 Sample Course Data
- [ ] Create `backend/data/courses.json` with 2-3 sample courses
- [ ] Topics: "French Basics - Greetings", "French Travel Essentials"
- [ ] Each course: 5-10 lessons
- [ ] Each lesson: 3-5 exercises (phrases to practice)

### 1.3 Course Service Layer
- [ ] Create `backend/services/course_service.py`
- [ ] Functions: get_all_courses(), get_course_by_id(), get_lessons(), get_exercise()
- [ ] Load from JSON (later: database)

---

## Phase 2: Backend API Endpoints

### 2.1 Course Discovery Endpoints
- [ ] `GET /api/courses` - List all courses
- [ ] `GET /api/courses/{courseId}` - Get course details
- [ ] `GET /api/courses/{courseId}/lessons` - Get lessons for course
- [ ] `GET /api/lessons/{lessonId}` - Get lesson with exercises

### 2.2 Practice Endpoint (Core Feature)
- [ ] `POST /api/practice` - Submit user audio for pronunciation check
  - Accept: audio file, exerciseId, expectedText (French phrase)
  - Process: STT → compare with expected → score pronunciation
  - Return: transcription, scores, feedback, next exercise

### 2.3 Progress Endpoints
- [ ] `GET /api/progress/{userId}` - Get user's overall progress
- [ ] `POST /api/progress/{userId}/complete` - Mark lesson complete
- [ ] `GET /api/progress/{userId}/course/{courseId}` - Course-specific progress

---

## Phase 3: AI Integration (OpenAI APIs)

### 3.1 Activate Speech-to-Text (Whisper)
- [ ] Update `services/stt.py` - Real Whisper API call
- [ ] Save uploaded audio to temp file (Whisper needs file path)
- [ ] Handle language detection (French primary)
- [ ] Add error handling & retries

### 3.2 Pronunciation Evaluation (GPT-4)
- [ ] Create `services/pronunciation.py`
- [ ] Function: `evaluate_pronunciation(expected, transcribed, language)`
- [ ] Use GPT to compare texts and score:
  - Accuracy: how close to target
  - Fluency: naturalness
  - Completeness: all words spoken
  - Overall score + actionable feedback
- [ ] Return PronunciationScore model

### 3.3 Activate Text-to-Speech
- [ ] Update `services/tts.py` - Real OpenAI TTS call
- [ ] Support French voices (alloy, nova, etc.)
- [ ] Return actual audio bytes as base64
- [ ] Add voice selection per language

---

## Phase 4: Backend Infrastructure

### 4.1 CORS & Middleware
- [ ] Add CORS middleware to `main.py`
- [ ] Allow Flutter app origin (localhost + emulator IPs)
- [ ] Add request logging middleware
- [ ] Add error handling middleware

### 4.2 Environment & Setup
- [ ] Create `.env.example` with required keys:
  - OPENAI_API_KEY
  - CORS_ORIGINS
  - DATA_PATH
- [ ] Create `backend/setup.sh` script
- [ ] Update `requirements.txt` if needed
- [ ] Add `backend/README.md` with setup instructions

### 4.3 File Upload Handling
- [ ] Create temp directory for audio uploads
- [ ] Add cleanup logic (delete after processing)
- [ ] Handle file size limits
- [ ] Support multiple audio formats (wav, m4a, webm)

---

## Phase 5: Flutter Frontend - Data Layer

### 5.1 Models
- [ ] `lib/models/course.dart` - Course, Lesson, Exercise, Phrase
- [ ] `lib/models/pronunciation_score.dart`
- [ ] `lib/models/user_progress.dart`
- [ ] Add json_serializable annotations
- [ ] Generate with `flutter pub run build_runner build`

### 5.2 API Service
- [ ] `lib/services/api_service.dart`
  - getCourses()
  - getCourse(id)
  - getLessons(courseId)
  - submitPractice(audio, exerciseId, expectedText)
  - getProgress(userId)
  - markComplete(userId, lessonId)

### 5.3 Audio Service
- [ ] `lib/services/audio_service.dart`
  - recordAudio() → returns File
  - playAudio(base64Audio)
  - stopPlayback()
  - Clean temp files

---

## Phase 6: Flutter Frontend - UI Screens

### 6.1 Course List Screen
- [ ] `lib/screens/course_list_screen.dart`
- [ ] Display grid/list of available courses
- [ ] Show: title, description, difficulty, progress %
- [ ] Tap course → navigate to LessonListScreen

### 6.2 Lesson List Screen
- [ ] `lib/screens/lesson_list_screen.dart`
- [ ] Show lessons for selected course
- [ ] Display: lesson title, completion status, estimated time
- [ ] Tap lesson → navigate to PracticeScreen

### 6.3 Practice Screen (Main Feature)
- [ ] `lib/screens/practice_screen.dart`
- [ ] Layout:
  1. Top: Progress indicator (1/5 exercises)
  2. English sentence display
  3. "Tap to hear French" button → play TTS
  4. French text display (hidden initially, revealed after hearing)
  5. "Hold to record" button (large, center)
  6. Feedback area (pronunciation score, encouragement)
- [ ] Flow:
  - Show English → User taps to hear French → User records
  - Submit to backend → Show results → Next exercise

### 6.4 Result/Feedback Widget
- [ ] `lib/widgets/pronunciation_feedback.dart`
- [ ] Show scores with visual bars/gauges
- [ ] Display transcribed vs expected text (diff highlighting)
- [ ] Encouragement message
- [ ] "Try Again" or "Next" button

---

## Phase 7: State Management & Logic

### 7.1 Providers
- [ ] `lib/providers/course_provider.dart`
  - Load courses, cache locally
  - Track selected course/lesson
- [ ] `lib/providers/practice_provider.dart`
  - Manage practice session state
  - Handle recording, submission, results
  - Track exercise progress within lesson
- [ ] `lib/providers/progress_provider.dart`
  - Load/save user progress
  - Update completion status
  - Calculate statistics

### 7.2 Local Storage
- [ ] Use SharedPreferences or Hive
- [ ] Cache: userId, completed lessons, scores
- [ ] Persist progress offline

---

## Phase 8: Polish & UX

### 8.1 Loading & Error States
- [ ] Shimmer loading for course list
- [ ] Retry buttons on errors
- [ ] Offline mode messaging
- [ ] Audio loading indicators

### 8.2 Animations
- [ ] Page transitions
- [ ] Score reveal animations
- [ ] Recording pulse animation
- [ ] Confetti on lesson completion

### 8.3 Accessibility
- [ ] Screen reader support (like real Natulang)
- [ ] High contrast mode
- [ ] Large text option
- [ ] Haptic feedback

---

## Phase 9: Testing & Deployment

### 9.1 Backend Tests
- [ ] Unit tests for pronunciation evaluation
- [ ] API endpoint tests
- [ ] Load sample courses successfully

### 9.2 Flutter Tests
- [ ] Widget tests for key screens
- [ ] Provider tests
- [ ] Audio recording/playback tests

### 9.3 Integration Test
- [ ] End-to-end: select course → complete exercise → get feedback

---

## Priority Order (What to Build First)

1. **Backend sample data** (courses.json) ✓ NEXT
2. **Course service & endpoints** 
3. **Activate OpenAI STT** (critical for audio)
4. **Pronunciation evaluation** (core feature)
5. **Activate TTS** (for hearing French)
6. **CORS setup**
7. **Flutter models & API service**
8. **Practice screen UI** (the main user interaction)
9. **Course list screen**
10. **Progress tracking**
11. **Polish & animations**

---

## Success Criteria

✅ User can browse courses by topic
✅ User can select a lesson
✅ User sees English sentence
✅ User hears French pronunciation (TTS)
✅ User records their pronunciation
✅ System transcribes and scores pronunciation
✅ User receives encouraging feedback
✅ Progress is tracked
✅ App works hands-free (audio-first)

---

## Next Immediate Steps

1. Create `backend/data/courses.json` with sample French courses
2. Implement `backend/services/course_service.py`
3. Add course endpoints to `main.py`
4. Activate OpenAI Whisper in `services/stt.py`
5. Create `services/pronunciation.py` with GPT evaluation
