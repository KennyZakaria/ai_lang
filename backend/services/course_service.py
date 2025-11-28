import json
import os
from typing import List, Optional, Dict
from pathlib import Path

# Load courses data from JSON file
DATA_PATH = Path(__file__).parent.parent / "data" / "courses.json"

_courses_data: Optional[Dict] = None

def _load_data():
    """Load courses data from JSON file (cached)"""
    global _courses_data
    if _courses_data is None:
        with open(DATA_PATH, 'r', encoding='utf-8') as f:
            _courses_data = json.load(f)
    return _courses_data

def get_all_courses() -> List[Dict]:
    """Get all available courses"""
    data = _load_data()
    return data.get("courses", [])

def get_course_by_id(course_id: str) -> Optional[Dict]:
    """Get a specific course by ID"""
    courses = get_all_courses()
    for course in courses:
        if course["id"] == course_id:
            return course
    return None

def get_lessons_by_course(course_id: str) -> List[Dict]:
    """Get all lessons for a specific course"""
    data = _load_data()
    lessons = data.get("lessons", [])
    course_lessons = [l for l in lessons if l["courseId"] == course_id]
    # Sort by order
    return sorted(course_lessons, key=lambda x: x["order"])

def get_lesson_by_id(lesson_id: str) -> Optional[Dict]:
    """Get a specific lesson by ID"""
    data = _load_data()
    lessons = data.get("lessons", [])
    for lesson in lessons:
        if lesson["id"] == lesson_id:
            return lesson
    return None

def get_exercise_by_id(lesson_id: str, exercise_id: str) -> Optional[Dict]:
    """Get a specific exercise from a lesson"""
    lesson = get_lesson_by_id(lesson_id)
    if not lesson:
        return None
    
    exercises = lesson.get("exercises", [])
    for exercise in exercises:
        if exercise["id"] == exercise_id:
            return exercise
    return None

def get_next_exercise(lesson_id: str, current_exercise_id: str) -> Optional[Dict]:
    """Get the next exercise in a lesson, or None if this is the last one"""
    lesson = get_lesson_by_id(lesson_id)
    if not lesson:
        return None
    
    exercises = lesson.get("exercises", [])
    for i, exercise in enumerate(exercises):
        if exercise["id"] == current_exercise_id:
            if i + 1 < len(exercises):
                return exercises[i + 1]
            return None
    return None
