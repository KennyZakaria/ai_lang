import 'package:flutter/material.dart';
import '../models/chat_turn.dart';

class ChatBubble extends StatelessWidget {
  final ChatTurn turn;

  const ChatBubble({super.key, required this.turn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User message
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    turn.user,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // AI response
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.smart_toy, color: theme.colorScheme.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    turn.ai,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            
            // Corrections
            if (turn.corrections.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Corrections:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...turn.corrections.map((c) => Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          c.original,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          c.corrected,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (c.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          c.note,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
            ],
            
            // Suggestions
            if (turn.suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Suggestions:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...turn.suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.blue.shade700)),
                    Expanded(
                      child: Text(
                        s,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            // Timestamp
            const SizedBox(height: 8),
            Text(
              _formatTime(turn.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
