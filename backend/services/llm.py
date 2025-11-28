import os
import json
from typing import Dict, List

try:
    from openai import OpenAI
    _llm_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
except Exception:
    _llm_client = None

SYSTEM_PROMPT = """You are a patient language tutor. Provide:
- reply: natural response advancing conversation.
- corrections: array of {original, corrected, note} only if needed.
- suggestions: short actionable next practice tips.
- nextPrompt: a suggested next user prompt.
Respond strictly in JSON.
"""

def build_user_prompt(transcript: str, target_language: str, proficiency: str | None, history: List[Dict]) -> str:
    history_text = "\n".join([f"User: {h['user']}\nAI: {h['ai']}" for h in history[-6:]])
    prof_line = f"Proficiency: {proficiency}" if proficiency else ""
    return f"Conversation so far:\n{history_text}\nCurrent user input: {transcript}\nTarget language: {target_language}\n{prof_line}\nReturn valid JSON."

def parse_llm_json(raw: str) -> Dict:
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        # Attempt to extract JSON substring
        start = raw.find('{')
        end = raw.rfind('}')
        if start != -1 and end != -1:
            try:
                return json.loads(raw[start:end+1])
            except Exception:
                pass
    return {
        "reply": raw.strip(),
        "corrections": [],
        "suggestions": ["Speak more slowly."],
        "nextPrompt": None,
        "meta": {"fallback": True}
    }

def generate_chat(transcript: str, target_language: str, proficiency: str | None, history: List[Dict]) -> Dict:
    if _llm_client:
        try:
            prompt = build_user_prompt(transcript, target_language, proficiency, history)
            # Pseudocode for chat completion; adjust to actual SDK method.
            # response = _llm_client.chat.completions.create(model="gpt-4o-mini", messages=[{"role":"system","content":SYSTEM_PROMPT},{"role":"user","content":prompt}])
            # raw = response.choices[0].message.content
            raw = "{\"reply\": \"(stub LLM reply)\", \"corrections\": [], \"suggestions\": [\"Try past tense.\"], \"nextPrompt\": \"Describe your morning.\", \"meta\": {\"provider\": \"openai\"}}"
            data = parse_llm_json(raw)
            data.setdefault("meta", {})
            data["meta"].update({"provider": "openai"})
            return data
        except Exception:
            pass

    # Fallback stub
    return {
        "reply": f"You said: '{transcript}'. Let's practice {target_language} more.",
        "corrections": [],
        "suggestions": ["Form a past tense sentence."],
        "nextPrompt": "Describe what you did yesterday.",
        "meta": {"provider": "stub"}
    }
