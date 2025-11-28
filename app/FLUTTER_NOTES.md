# Flutter App Development Notes

## Current Structure

### Services Layer (`lib/services/`)
- **api_service.dart**: Handles all HTTP communication with backend
  - Session management
  - STT, Chat, TTS endpoints
  - Error handling with custom ApiException
  - Configurable base URL for different environments

### Models (`lib/models/`)
- **correction.dart**: Correction model with json_serializable
- **chat_response.dart**: API response structure
- **chat_turn.dart**: UI-level conversation turn data
- **transcript_response.dart**: STT response structure

### Providers (`lib/providers/`)
- **conversation_provider.dart**: Main state management
  - Recording state machine (idle, recording, transcribing, thinking, speaking)
  - Audio recording and playback
  - API orchestration
  - Error handling
  - Language selection

### Widgets (`lib/widgets/`)
- **chat_bubble.dart**: Rich conversation display with corrections and suggestions
- **recording_button.dart**: Animated recording control with state indicators

## Features Implemented
✅ Modular architecture with separation of concerns
✅ State machine for conversation flow
✅ Error handling and user feedback
✅ Language selection (10 languages supported)
✅ Rich UI with corrections and suggestions display
✅ Loading states and progress indicators
✅ Session management
✅ Audio recording and playback
✅ Responsive design with Material 3

## To Generate Model Code
Run this to generate json_serializable code:
```bash
cd app
flutter pub run build_runner build --delete-conflicting-outputs
```

## Environment Configuration
- Default API base URL: `http://10.0.2.2:8000` (Android emulator)
- For iOS simulator: change to `http://localhost:8000`
- For physical device: use your machine's IP address

## Next Steps
1. Run `flutter pub run build_runner build` to generate model code
2. Test with backend running
3. Add offline mode capabilities
4. Implement pronunciation scoring visualization
5. Add conversation history persistence
6. Implement user authentication
