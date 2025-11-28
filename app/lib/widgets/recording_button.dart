import 'package:flutter/material.dart';
import '../providers/conversation_provider.dart';

class RecordingButton extends StatelessWidget {
  final ConversationProvider provider;

  const RecordingButton({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isRecording = provider.isRecording;
    final isProcessing = provider.isProcessing;
    final state = provider.state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // State indicator
        if (isProcessing)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStateText(state),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

        // Recording button
        GestureDetector(
          onTap: isProcessing ? null : () => provider.toggleRecording(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isRecording
                  ? Colors.red.shade400
                  : (isProcessing ? Colors.grey.shade400 : Colors.blue.shade600),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isRecording ? Colors.red : Colors.blue).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Button label
        Text(
          isRecording ? 'Tap to Stop' : 'Tap to Speak',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  String _getStateText(ConversationState state) {
    switch (state) {
      case ConversationState.transcribing:
        return 'Transcribing...';
      case ConversationState.thinking:
        return 'Thinking...';
      case ConversationState.speaking:
        return 'Speaking...';
      default:
        return '';
    }
  }
}
