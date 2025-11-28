import os
from typing import Tuple
import base64

try:
    from openai import OpenAI
    _tts_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
except Exception:
    _tts_client = None

# Voice mapping for different languages
VOICE_MAP = {
    "fr": "alloy",  # French - clear, neutral
    "es": "nova",   # Spanish - warm
    "de": "onyx",   # German - deep
    "en": "echo",   # English - clear
    "default": "alloy"
}

def synthesize(text: str, voice: str | None, language: str | None, provider: str | None) -> Tuple[str, str, int, str]:
    """
    Generate speech audio from text.
    Returns: (base64_audio, format, duration_ms, provider)
    """
    chosen_provider = provider or ("openai-tts" if _tts_client else "stub")
    
    if _tts_client and chosen_provider.startswith("openai"):
        try:
            # Select appropriate voice for language
            lang_code = (language or "en")[:2].lower()
            selected_voice = voice or VOICE_MAP.get(lang_code, VOICE_MAP["default"])
            
            # Call OpenAI TTS API
            response = _tts_client.audio.speech.create(
                model="tts-1",  # or "tts-1-hd" for higher quality
                voice=selected_voice,
                input=text,
                response_format="mp3"
            )
            
            # Get audio bytes
            audio_bytes = response.content
            
            # Encode to base64
            b64 = base64.b64encode(audio_bytes).decode('utf-8')
            
            # Estimate duration (rough: ~150 words per minute for TTS)
            words = len(text.split())
            duration_ms = int((words / 150) * 60 * 1000)
            
            return b64, "mp3", duration_ms, "openai"
            
        except Exception as e:
            print(f"TTS error: {e}")
            # Fall through to stub

    # Fallback stub (empty audio)
    return "", "mp3", 0, "stub"
