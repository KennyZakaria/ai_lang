# Natulang Voice-Based Language Learning App

## Overview
Natulang is a cross-platform (Android/iOS) Flutter application enabling immersive AI-driven language learning via spoken conversations. Users speak; the app records audio, sends it to a backend for transcription (Whisper), semantic understanding (LLM), corrective feedback, and returns both text + synthesized speech (TTS) for the AI response.

## High-Level Architecture
Client (Flutter) ↔ FastAPI Backend ↔ External AI Services

- Speech-to-Text (STT): OpenAI Whisper API (or local open-source Whisper for offline/GPU)
- AI Conversation Engine: OpenAI GPT-4o / GPT-4.1 (fallback: any hosted LLM endpoint)
- Text-to-Speech (TTS): OpenAI, ElevenLabs, or Google Cloud TTS
- Session State: Maintained server-side (Redis optional) with conversation context + user proficiency metrics

```
[Flutter App]
  |-- record audio (.wav/.m4a)
  |-- send /stt → transcript
  |-- send /chat (transcript + context) → AI reply w/ corrections
  |-- request /tts for AI reply audio
  |-- play audio, display text & feedback

[FastAPI Backend]
  /stt  : audio upload → Whisper → TranscriptResponse
  /chat : ChatRequest (transcript, lang, sessionId) → LLM prompt engineering → ChatResponse
  /tts  : TTSRequest (text, voice, lang) → provider API → returns audio bytes (base64)
  /session : create/list/update conversation state

[External Services]
  Whisper, GPT, TTS providers (OpenAI, ElevenLabs, etc.)
```

## Data Flow
1. User taps mic → recording starts.
2. User stops → audio file uploaded to `/stt`.
3. Backend returns transcript.
4. Client sends transcript to `/chat` with session ID.
5. Backend crafts prompt (context + correction strategy) → LLM response with: reply, corrections, suggestions, next prompt.
6. Client optionally calls `/tts` for spoken AI reply.
7. Playback + UI update (feedback overlays).

## Backend Endpoints (Initial)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/stt` | POST (multipart) | Audio → text |
| `/chat` | POST | Generate reply + feedback |
| `/tts` | POST | Text → speech |
| `/session` | POST | Create session |

## Models (Draft)
- TranscriptRequest: audio file (multipart), languageCode
- TranscriptResponse: text, confidence
- ChatRequest: transcript, sessionId, targetLanguage, proficiencyLevel?
- ChatResponse: reply, corrections[], suggestions[], nextPrompt, meta
- TTSRequest: text, voice, languageCode
- TTSResponse: audioBase64, format, durationMs

## Prompt Engineering (Sketch)
System prompt components:
- Role: "You are a patient language tutor."
- Language mode: targetLanguage
- Correction style: minimal, focus on pronunciation & grammar, provide 1–2 examples
- Provide JSON schema in response → parsed into ChatResponse

## Flutter Packages (Planned)
- `record` (audio capture)
- `dio` (networking + multipart)
- `provider` or `riverpod` (state mgmt)
- `just_audio` (playback)
- `speech_to_text` (optional fallback)
- `json_annotation`, `build_runner` (model serialization)

## Python Backend Dependencies (Planned)
```
fastapi
uvicorn
openai
whisper
pydantic
python-multipart
redis (optional for session)
torch (if local Whisper)
```

## Environment Variables
```
OPENAI_API_KEY=...
ELEVENLABS_API_KEY=... (optional)
WHISPER_MODE=remote|local
REDIS_URL=redis://localhost:6379 (optional)
```

## Setup
### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Flutter
```bash
cd app
flutter pub get
flutter run
```

## Security Notes
- Use token-based auth (e.g. JWT) per session
- Enforce rate limits on STT & TTS endpoints
- Validate audio MIME types & duration limits

## Scaling Considerations
- Queue long TTS/STT jobs (Celery / Redis)
- Cache repeated TTS outputs
- Stream partial STT results (future)
- GPU nodes for Whisper local inference

## Roadmap (Next Milestones)
1. Implement stub endpoints + models
2. Integrate OpenAI Whisper remote
3. Add conversation state store (in-memory → Redis)
4. Add TTS provider abstraction
5. Add pronunciation scoring (phoneme alignment)
6. Implement real-time VAD streaming
7. Add spaced repetition scheduler

## License
TBD
