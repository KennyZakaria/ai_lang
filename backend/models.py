from pydantic import BaseModel
from typing import List, Optional, Dict
from enum import Enum

# === Course & Lesson Models ===

class DifficultyLevel(str, Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"

class Phrase(BaseModel):
    id: str
    english: str
    target: str  # French, Spanish, etc.
    audioUrl: Optional[str] = None
    phonetic: Optional[str] = None

class Exercise(BaseModel):
    id: str
    type: str  # "listen_repeat", "translate", "conversation"
    phrase: Phrase
    hints: List[str] = []

class Lesson(BaseModel):
    id: str
    title: str
    description: str
    courseId: str
    exercises: List[Exercise]
    order: int
    estimatedMinutes: int = 5

class Course(BaseModel):
    id: str
    title: str
    description: str
    targetLanguage: str
    difficulty: DifficultyLevel
    topicCategory: str  # "greetings", "travel", "business", etc.
    lessonsCount: int
    imageUrl: Optional[str] = None

# === API Request/Response Models ===

class TranscriptRequest(BaseModel):
    languageCode: str = "en"

class TranscriptResponse(BaseModel):
    text: str
    confidence: float = 0.0
    provider: str = "stub"

class PronunciationScore(BaseModel):
    accuracy: float  # 0-100
    fluency: float  # 0-100
    completeness: float  # 0-100
    overall: float  # 0-100
    feedback: str

class PracticeRequest(BaseModel):
    lessonId: str
    exerciseId: str
    expectedText: str  # The French phrase they should say
    userId: str

class PracticeResponse(BaseModel):
    transcribedText: str
    expectedText: str
    pronunciationScore: PronunciationScore
    isCorrect: bool
    encouragement: str
    nextExerciseId: Optional[str] = None

class TTSRequest(BaseModel):
    text: str
    languageCode: str = "fr"
    voice: Optional[str] = None
    provider: Optional[str] = None

class TTSResponse(BaseModel):
    audioBase64: str
    format: str = "mp3"
    durationMs: Optional[int] = None
    provider: str = "stub"

class UserProgress(BaseModel):
    userId: str
    courseId: str
    completedLessons: List[str] = []
    currentLessonId: Optional[str] = None
    averageScore: float = 0.0
    totalPracticeTime: int = 0  # minutes

class SessionCreateResponse(BaseModel):
    sessionId: str
    created: bool = True
