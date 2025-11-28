import os
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from typing import Dict, List

from models import (
    TranscriptResponse,
    TTSRequest,
    TTSResponse,
    SessionCreateResponse,
    Course,
    Lesson,
    PracticeRequest,
    PracticeResponse,
    PronunciationScore,
    UserProgress,
)
from services.stt import transcribe_audio
from services.tts import synthesize
from services import course_service
from services.pronunciation import evaluate_pronunciation

load_dotenv()

app = FastAPI(title="Natulang Backend", version="0.3.0")

# CORS configuration - allow Flutter app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production: specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory stores (later replace with Redis/DB)
SESSIONS: Dict[str, Dict] = {}
USER_PROGRESS: Dict[str, UserProgress] = {}

def _ensure_session(session_id: str):
    if session_id not in SESSIONS:
        SESSIONS[session_id] = {"history": []}
    return SESSIONS[session_id]

def _get_user_progress(user_id: str, course_id: str = None) -> UserProgress:
    """Get or create user progress"""
    key = f"{user_id}:{course_id}" if course_id else user_id
    if key not in USER_PROGRESS:
        USER_PROGRESS[key] = UserProgress(
            userId=user_id,
            courseId=course_id or "",
            completedLessons=[],
            averageScore=0.0,
            totalPracticeTime=0
        )
    return USER_PROGRESS[key]

# === Course Endpoints ===

@app.get("/api/courses", response_model=List[Course])
async def get_courses():
    """Get all available courses"""
    courses = course_service.get_all_courses()
    return courses

@app.get("/api/courses/{course_id}", response_model=Course)
async def get_course(course_id: str):
    """Get a specific course by ID"""
    course = course_service.get_course_by_id(course_id)
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    return course

@app.get("/api/courses/{course_id}/lessons", response_model=List[Lesson])
async def get_course_lessons(course_id: str):
    """Get all lessons for a course"""
    lessons = course_service.get_lessons_by_course(course_id)
    return lessons

@app.get("/api/lessons/{lesson_id}", response_model=Lesson)
async def get_lesson(lesson_id: str):
    """Get a specific lesson with exercises"""
    lesson = course_service.get_lesson_by_id(lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return lesson

# === Practice Endpoint (Core Feature) ===

@app.post("/api/practice", response_model=PracticeResponse)
async def practice_exercise(
    file: UploadFile = File(...),
    lessonId: str = "",
    exerciseId: str = "",
    expectedText: str = "",
    userId: str = "default-user",
    languageCode: str = "fr"
):
    """
    Submit user's pronunciation for evaluation.
    - Transcribe audio using Whisper
    - Compare with expected phrase
    - Score pronunciation
    - Return feedback and next exercise
    """
    try:
        # 1. Transcribe the audio
        transcribed, confidence, provider = await transcribe_audio(file, languageCode)
        
        # 2. Evaluate pronunciation
        score_data = evaluate_pronunciation(expectedText, transcribed, "French")
        pronunciation_score = PronunciationScore(**score_data)
        
        # 3. Determine if correct (threshold: 70%)
        is_correct = pronunciation_score.overall >= 70.0
        
        # 4. Get encouragement message
        if pronunciation_score.overall >= 90:
            encouragement = "🎉 Perfect! Excellent pronunciation!"
        elif pronunciation_score.overall >= 75:
            encouragement = "✨ Great job! Well done!"
        elif pronunciation_score.overall >= 60:
            encouragement = "👍 Good effort! Keep practicing!"
        else:
            encouragement = "💪 Keep trying! You're learning!"
        
        # 5. Get next exercise (if this one was completed)
        next_exercise = None
        if is_correct:
            next_ex = course_service.get_next_exercise(lessonId, exerciseId)
            if next_ex:
                next_exercise = next_ex.get("id")
            else:
                # Lesson complete!
                progress = _get_user_progress(userId, lessonId.split("-lesson-")[0] if "lesson" in lessonId else "")
                if lessonId not in progress.completedLessons:
                    progress.completedLessons.append(lessonId)
        
        # 6. Update user progress stats
        progress = _get_user_progress(userId)
        # Update average score (simple rolling average)
        current_avg = progress.averageScore
        total_scores = len(progress.completedLessons) or 1
        progress.averageScore = (current_avg * (total_scores - 1) + pronunciation_score.overall) / total_scores
        
        return PracticeResponse(
            transcribedText=transcribed,
            expectedText=expectedText,
            pronunciationScore=pronunciation_score,
            isCorrect=is_correct,
            encouragement=encouragement,
            nextExerciseId=next_exercise
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Practice error: {str(e)}")

# === Progress Endpoints ===

@app.get("/api/progress/{user_id}")
async def get_user_progress(user_id: str):
    """Get user's overall progress"""
    progress = _get_user_progress(user_id)
    return progress

@app.get("/api/progress/{user_id}/course/{course_id}")
async def get_course_progress(user_id: str, course_id: str):
    """Get user's progress for specific course"""
    progress = _get_user_progress(user_id, course_id)
    return progress

# === STT & TTS Endpoints ===

@app.post("/stt", response_model=TranscriptResponse)
async def stt_endpoint(file: UploadFile = File(...), languageCode: str = "en"):
    try:
        text, confidence, provider = await transcribe_audio(file, languageCode)
        return TranscriptResponse(text=text, confidence=confidence, provider=provider)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"STT error: {e}")

@app.post("/api/tts", response_model=TTSResponse)
async def tts_endpoint(req: TTSRequest):
    try:
        b64, fmt, dur, provider = synthesize(req.text, req.voice, req.languageCode, req.provider)
        return TTSResponse(audioBase64=b64, format=fmt, durationMs=dur, provider=provider)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"TTS error: {e}")

@app.post("/api/session", response_model=SessionCreateResponse)
async def create_session():
    import uuid
    session_id = f"sess-{uuid.uuid4().hex[:8]}"
    _ensure_session(session_id)
    return SessionCreateResponse(sessionId=session_id)

@app.get("/health")
async def health():
    return {"status": "ok", "courses": len(course_service.get_all_courses())}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
