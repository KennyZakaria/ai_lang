import os
import json
from typing import Dict

try:
    from openai import OpenAI
    _eval_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
except Exception:
    _eval_client = None

def evaluate_pronunciation(expected_text: str, transcribed_text: str, language: str = "French") -> Dict:
    """
    Use GPT to evaluate pronunciation by comparing expected vs transcribed text.
    Returns a PronunciationScore dict with accuracy, fluency, completeness, overall, and feedback.
    """
    
    if not transcribed_text or transcribed_text.strip() == "":
        return {
            "accuracy": 0.0,
            "fluency": 0.0,
            "completeness": 0.0,
            "overall": 0.0,
            "feedback": "No speech detected. Please try speaking again."
        }
    
    # If OpenAI is available, use GPT for intelligent evaluation
    if _eval_client:
        try:
            system_prompt = f"""You are a {language} pronunciation expert. Compare the expected phrase with what the user actually said.
Score the pronunciation on:
1. accuracy: how closely the transcribed text matches the expected (0-100)
2. fluency: how natural/smooth the pronunciation sounds (0-100)
3. completeness: whether all words were spoken (0-100)
4. overall: weighted average score (0-100)

Also provide brief, encouraging feedback in English (1-2 sentences).

Return ONLY valid JSON in this exact format:
{{
  "accuracy": <number>,
  "fluency": <number>,
  "completeness": <number>,
  "overall": <number>,
  "feedback": "<string>"
}}"""

            user_prompt = f"""Expected: "{expected_text}"
Transcribed: "{transcribed_text}"

Evaluate the pronunciation."""

            response = _eval_client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.3,
                response_format={"type": "json_object"}
            )
            
            raw = response.choices[0].message.content
            result = json.loads(raw)
            
            # Ensure all required fields
            result.setdefault("accuracy", 0.0)
            result.setdefault("fluency", 0.0)
            result.setdefault("completeness", 0.0)
            result.setdefault("overall", 0.0)
            result.setdefault("feedback", "Good try!")
            
            return result
            
        except Exception as e:
            print(f"GPT evaluation error: {e}")
            # Fall through to simple evaluation
    
    # Fallback: Simple string similarity evaluation
    expected_clean = expected_text.lower().strip()
    transcribed_clean = transcribed_text.lower().strip()
    
    # Simple word-level comparison
    expected_words = expected_clean.split()
    transcribed_words = transcribed_clean.split()
    
    # Completeness: how many expected words are present
    matched_words = sum(1 for w in expected_words if w in transcribed_clean)
    completeness = (matched_words / len(expected_words) * 100) if expected_words else 0
    
    # Accuracy: exact match or Levenshtein-like similarity
    if expected_clean == transcribed_clean:
        accuracy = 100.0
    elif transcribed_clean in expected_clean or expected_clean in transcribed_clean:
        accuracy = 85.0
    else:
        # Simple ratio
        accuracy = max(0, 100 - (abs(len(expected_clean) - len(transcribed_clean)) * 2))
    
    # Fluency: assume decent if words match
    fluency = completeness * 0.8  # rough estimate
    
    # Overall
    overall = (accuracy * 0.4 + fluency * 0.3 + completeness * 0.3)
    
    # Feedback
    if overall >= 90:
        feedback = "Excellent pronunciation! Perfect!"
    elif overall >= 75:
        feedback = "Very good! Keep practicing."
    elif overall >= 50:
        feedback = "Good attempt. Try to pronounce more clearly."
    else:
        feedback = "Keep trying! Listen carefully and repeat."
    
    return {
        "accuracy": round(accuracy, 1),
        "fluency": round(fluency, 1),
        "completeness": round(completeness, 1),
        "overall": round(overall, 1),
        "feedback": feedback
    }
