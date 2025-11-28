import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/practice_provider.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<PracticeProvider>(
          builder: (context, provider, _) => Text(
            provider.currentLesson?.title ?? 'Practice',
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<PracticeProvider>(
        builder: (context, provider, _) {
          if (provider.currentLesson == null) {
            return const Center(child: Text('No lesson selected'));
          }

          if (provider.currentExercise == null) {
            return const Center(child: Text('No exercises available'));
          }

          // Show results view
          if (provider.state == PracticeState.showingResults &&
              provider.lastResponse != null) {
            return _ResultsView(provider: provider);
          }

          // Show practice view
          return _PracticeView(provider: provider);
        },
      ),
    );
  }
}

class _PracticeView extends StatelessWidget {
  final PracticeProvider provider;

  const _PracticeView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final exercise = provider.currentExercise!;
    final phrase = exercise.phrase;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${provider.currentExerciseIndex + 1} of ${provider.totalExercises}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${((provider.currentExerciseIndex / provider.totalExercises) * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: provider.currentExerciseIndex / provider.totalExercises,
            backgroundColor: Colors.grey[200],
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),

          // English phrase
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'English',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  phrase.english,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // French phrase with audio
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.shade200, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'French',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    if (provider.state == PracticeState.playingFrench)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.purple.shade700),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: provider.playFrenchAudio,
                        icon: Icon(Icons.volume_up, color: Colors.purple.shade700),
                        tooltip: 'Hear pronunciation',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  phrase.target,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (phrase.phonetic != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    phrase.phonetic!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.purple.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Hints
          if (exercise.hints.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Hints',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...exercise.hints.map((hint) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $hint'),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Recording button
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: (_) => provider.startRecording(),
                  onTapUp: (_) => provider.stopRecordingAndSubmit(),
                  onTapCancel: () => provider.stopRecordingAndSubmit(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isRecording
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      boxShadow: provider.isRecording
                          ? [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      provider.isRecording ? Icons.stop : Icons.mic,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.isRecording
                      ? 'Recording... Release to submit'
                      : provider.state == PracticeState.submitting
                          ? 'Evaluating...'
                          : 'Hold to record',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: provider.isRecording ? Colors.red : null,
                      ),
                ),
              ],
            ),
          ),

          // Error message
          if (provider.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => provider.clearError(),
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final PracticeProvider provider;

  const _ResultsView({required this.provider});

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final response = provider.lastResponse!;
    final score = response.pronunciationScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overall score
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getScoreColor(score.overall),
                  _getScoreColor(score.overall).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  response.encouragement,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '${score.overall.toInt()}%',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Overall Score',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detailed scores
          _ScoreBar(
            label: 'Accuracy',
            score: score.accuracy,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),
          _ScoreBar(
            label: 'Fluency',
            score: score.fluency,
            icon: Icons.speed,
          ),
          const SizedBox(height: 12),
          _ScoreBar(
            label: 'Completeness',
            score: score.completeness,
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 24),

          // Transcription comparison
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expected:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  response.expectedText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You said:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  response.transcribedText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: response.isCorrect ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Feedback
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.feedback_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    score.feedback,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          if (response.isCorrect && !provider.isLessonComplete)
            ElevatedButton.icon(
              onPressed: () => provider.nextExercise(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Exercise'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          else if (!response.isCorrect)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => provider.retryExercise(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => provider.nextExercise(),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Lesson Complete!'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score;
  final IconData icon;

  const _ScoreBar({
    required this.label,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${score.toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(
              score >= 75 ? Colors.green : score >= 50 ? Colors.orange : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
