# Natulang Implementation Status & Setup Guide

## ✅ COMPLETED - Backend (Phase 1-5)

### Data Models ✓
- Course, Lesson, Exercise, Phrase models with JSON serialization
- PronunciationScore for feedback
- PracticeRequest/Response for exercise submissions
- User progress tracking

### Sample Data ✓
- `backend/data/courses.json` with 3 courses:
  - **French Basics - Greetings** (3 lessons, 12 exercises)
  - **French Travel Essentials** (3 lessons, 10 exercises)
  - **Daily Conversations** (3 lessons, 12 exercises)
- Total: 9 lessons, 34 French phrases with phonetic guides

### Backend Services ✓
- **STT** (`services/stt.py`): Real OpenAI Whisper integration with temp file handling
- **TTS** (`services/tts.py`): Real OpenAI TTS with language-specific voice selection
- **Pronunciation** (`services/pronunciation.py`): GPT-4 powered evaluation with fallback
- **Course Service** (`services/course_service.py`): Load courses/lessons from JSON

### API Endpoints ✓
- `GET /api/courses` - List all courses
- `GET /api/courses/{id}` - Get course details
- `GET /api/courses/{id}/lessons` - Get course lessons
- `GET /api/lessons/{id}` - Get lesson with exercises
- `POST /api/practice` - Submit audio for pronunciation scoring (CORE FEATURE)
- `POST /api/tts` - Generate French speech audio
- `GET /api/progress/{userId}` - Get user progress
- `GET /health` - Health check

### Infrastructure ✓
- CORS middleware configured
- `.env.example` template
- `setup.sh` installation script
- Error handling & logging
- In-memory session & progress stores

---

## 🔄 IN PROGRESS - Flutter Frontend (Phase 6-8)

### Models Created ✓
- `lib/models/course.dart` - Course, Lesson, Exercise, Phrase
- `lib/models/pronunciation_score.dart` - PronunciationScore, PracticeResponse

### Services Created ✓
- `lib/services/api_service.dart` - Full API client with error handling

### Screens NEEDED 🔴
- ❌ `lib/screens/course_list_screen.dart`
- ❌ `lib/screens/lesson_list_screen.dart`
- ❌ `lib/screens/practice_screen.dart` **(MOST IMPORTANT)**
- ❌ Update `lib/main.dart` with new navigation

### Widgets NEEDED 🔴
- ❌ Pronunciation feedback widget (score display)
- ❌ Hold-to-record button widget
- ❌ French phrase display with audio button

### Providers NEEDED 🔴
- ❌ Course provider (load & cache courses)
- ❌ Practice provider (manage practice session state)

---

## 🚀 HOW TO RUN THE APP

### 1. Backend Setup

```bash
cd backend

# Run setup script
./setup.sh

# OR manual setup:
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env and add: OPENAI_API_KEY=sk-your-key-here

# Start server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Backend will run at:** `http://localhost:8000`  
**API Docs:** `http://localhost:8000/docs`

### 2. Flutter Setup

```bash
cd app

# Get dependencies
flutter pub get

# Generate JSON serialization code
flutter pub run build_runner build --delete-conflicting-outputs

# Run on Android emulator (backend on localhost)
flutter run

# OR run on physical device (update baseUrl to your machine's IP)
# In code, change: http://10.0.2.2:8000 to http://YOUR_IP:8000
flutter run
```

---

## 📋 WHAT WORKS NOW

### Backend ✅
- Load courses from JSON
- Transcribe user audio with Whisper
- Evaluate pronunciation with GPT-4
- Generate French TTS audio
- Score exercises (accuracy, fluency, completeness)
- Track user progress
- Provide encouraging feedback

### What You Can Test (via API docs at /docs):
1. GET `/api/courses` → See all courses
2. GET `/api/lessons/greetings-lesson-1` → See lesson with exercises
3. POST `/api/practice` → Upload audio + get pronunciation score
4. POST `/api/tts` with `{"text": "Bonjour", "languageCode": "fr"}` → Get French audio

---

## 🔴 WHAT'S MISSING (To Have Full App)

### Critical (Phase 6-7):
1. **Flutter Screens**:
   - Course list screen (browse topics)
   - Lesson list screen (see exercises)
   - **Practice screen** (main UI - show English/French, record, get feedback)

2. **State Management**:
   - Course provider
   - Practice session provider

3. **Audio Handling**:
   - Record audio widget
   - Play TTS audio widget
   - Save recordings to temp file

4. **Navigation**:
   - Course → Lessons → Practice flow
   - Back navigation with progress save

### Nice-to-Have (Phase 8):
- Progress visualization (charts, stats)
- Animations (score reveal, confetti on completion)
- Offline mode (cache courses)
- Spaced repetition scheduler
- Dark mode

---

## 🎯 CORE USER FLOW (When Complete)

1. **User opens app** → Sees course list (Greetings, Travel, etc.)
2. **Taps "French Basics - Greetings"** → Sees 3 lessons
3. **Taps "Basic Hello & Goodbye"** → Enters practice screen
4. **Exercise 1:**
   - Shows: "Hello" (English)
   - User taps 🔊 → Hears "Bonjour" (French TTS)
   - French text revealed: "Bonjour"
   - User holds mic button → Records pronunciation
   - Submits → Backend scores it
   - Shows: accuracy %, feedback, "Next" button
5. **Repeat for 4 exercises** → Lesson complete!
6. **Progress saved**, next lesson unlocked

---

## 🧪 TESTING CHECKLIST

### Backend Tests:
- [ ] Health endpoint returns 200
- [ ] Courses endpoint returns 3 courses
- [ ] Lesson endpoint returns exercises
- [ ] STT with real audio file returns transcript
- [ ] Pronunciation evaluation returns scores
- [ ] TTS returns base64 audio

### Flutter Tests (Once Built):
- [ ] Course list loads and displays
- [ ] Tapping course navigates to lessons
- [ ] Practice screen shows English/French
- [ ] TTS plays audio
- [ ] Recording captures audio
- [ ] Submit shows pronunciation feedback
- [ ] Next exercise works
- [ ] Lesson completion updates progress

---

## 💡 NEXT IMMEDIATE STEPS (Recommended Order)

1. ✅ Generate JSON serialization code for models:
   ```bash
   cd app
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Create **Practice Screen** (most important UI):
   - Layout with English/French text
   - "Tap to hear" button for TTS
   - "Hold to record" button
   - Pronunciation feedback display

3. Create **Course List Screen**:
   - Grid of courses
   - Navigate to lessons on tap

4. Create **Lesson List Screen**:
   - Show exercises for course
   - Navigate to practice

5. Wire up **Navigation** in `main.dart`

6. Create **Providers**:
   - CourseProvider (load courses)
   - PracticeProvider (manage session)

7. **Test end-to-end** with real audio

---

## 📦 DEPENDENCIES SUMMARY

### Backend Python:
- fastapi, uvicorn (web server)
- openai (STT, TTS, GPT evaluation)
- pydantic (data validation)
- python-dotenv (environment variables)
- python-multipart (file uploads)

### Flutter:
- dio (HTTP client)
- record (audio recording)
- just_audio (audio playback)
- provider (state management)
- json_annotation + build_runner (serialization)
- path_provider (temp file paths)
- permission_handler (mic permission)

---

## 🎓 LEARNING RESOURCES

- **OpenAI Whisper API**: https://platform.openai.com/docs/guides/speech-to-text
- **OpenAI TTS API**: https://platform.openai.com/docs/guides/text-to-speech
- **Flutter Record Package**: https://pub.dev/packages/record
- **Flutter just_audio**: https://pub.dev/packages/just_audio

---

## 🐛 KNOWN ISSUES / LIMITATIONS

1. **Backend**: In-memory storage (progress lost on restart) - later add Redis/DB
2. **Flutter**: JSON serialization not generated yet - run build_runner
3. **Audio**: Temp files need cleanup - add cleanup logic
4. **Network**: Hardcoded localhost - need environment config
5. **Auth**: No user authentication - add JWT later
6. **Offline**: No offline mode - add caching later

---

## 🔑 ENVIRONMENT VARIABLES

Backend `.env`:
```
OPENAI_API_KEY=sk-proj-...your-key...
CORS_ORIGINS=*
```

Get API key: https://platform.openai.com/api-keys

**Cost Estimate:**
- Whisper: $0.006/minute of audio
- TTS: $15/1M characters (~$0.015/request)
- GPT-4o-mini: $0.15/1M input tokens (~$0.002/evaluation)
- **Total per practice**: ~$0.02-0.03

---

## ✨ SUCCESS CRITERIA

App is "working" when:
✅ User can select a course
✅ User can see lesson exercises
✅ User can hear French pronunciation
✅ User can record their voice
✅ System scores pronunciation
✅ User receives feedback
✅ Progress is saved
✅ Can complete multiple exercises in sequence

This matches the Natulang app concept: speech-first, real-life dialogues, pronunciation practice!
