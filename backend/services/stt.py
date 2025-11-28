import os
import tempfile
from typing import Tuple
from fastapi import UploadFile
from pathlib import Path

try:
    from openai import OpenAI
    _openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
except Exception:
    _openai_client = None

async def transcribe_audio(file: UploadFile, language: str) -> Tuple[str, float, str]:
    """Return (text, confidence, provider). Fallback to stub if provider unavailable."""
    contents = await file.read()
    if not contents:
        return "", 0.0, "empty"

    # Real OpenAI Whisper API integration
    if _openai_client:
        temp_file = None
        try:
            # Save to temp file (Whisper API requires file object)
            suffix = Path(file.filename).suffix if file.filename else ".wav"
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
                temp_file.write(contents)
                temp_file.flush()
                temp_path = temp_file.name
            
            # Call Whisper API
            with open(temp_path, "rb") as audio_file:
                response = _openai_client.audio.transcriptions.create(
                    model="whisper-1",
                    file=audio_file,
                    language=language if language != "en" else None,  # Let Whisper auto-detect for English
                    response_format="verbose_json"
                )
            
            text = response.text
            # Whisper doesn't return confidence, but we can estimate from segments if available
            confidence = 0.9  # Default high confidence
            if hasattr(response, 'segments') and response.segments:
                # Average the no_speech_prob across segments (inverse)
                avg_speech_prob = sum(1 - seg.get('no_speech_prob', 0.1) for seg in response.segments) / len(response.segments)
                confidence = round(avg_speech_prob, 2)
            
            return text, confidence, "openai-whisper"
            
        except Exception as e:
            print(f"Whisper API error: {e}")
            # Fall through to stub
        finally:
            # Clean up temp file
            if temp_file and os.path.exists(temp_path):
                try:
                    os.unlink(temp_path)
                except:
                    pass

    # Stub fallback
    length = len(contents)
    return "(stub transcript)" if length else "", 0.0, "stub"
