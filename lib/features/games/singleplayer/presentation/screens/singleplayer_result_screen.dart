import 'package:flutter/material.dart';

class SingleplayerResultScreen extends StatelessWidget {
  final int score;
  final Map<String, dynamic>? summary;
  final List<Map<String, dynamic>> answers;
  final VoidCallback onDone;

  const SingleplayerResultScreen({
    super.key,
    required this.score,
    this.summary,
    required this.answers,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final correctCount = answers.where((a) => a['correct'] == true).length;
    final wrongCount = answers.length - correctCount;
    final finalScore = summary?['finalScore'] as int? ?? score;
    final totalCorrect = summary?['totalCorrect'] as int? ?? correctCount;
    final totalQuestions = summary?['totalQuestions'] as int? ?? answers.length;
    final accuracy = summary?['accuracyPercentage'] as int?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('¡Juego completado!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('Puntaje final: $finalScore', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StatChip(icon: Icons.check_circle, color: Colors.green.shade700, label: 'Correctas', value: '$totalCorrect'),
                      _StatChip(icon: Icons.cancel, color: Colors.red.shade700, label: 'Incorrectas', value: '${totalQuestions - totalCorrect}'),
                      if (accuracy != null)
                        _StatChip(icon: Icons.speed, color: Colors.blueGrey.shade700, label: 'Precisión', value: '$accuracy%'),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: answers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = answers[index];
                  final correct = item['correct'] as bool? ?? false;
                  final points = item['pointsGained'] ?? 0;
                  final Color statusColor = correct ? Colors.green.shade700 : Colors.red.shade700;
                  final IconData statusIcon = correct ? Icons.check_circle : Icons.cancel;

                  return Card(
                    elevation: 0,
                    color: correct ? Colors.green.shade50 : Colors.red.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: correct ? Colors.green.shade100 : Colors.red.shade100)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['questionText'] as String? ?? 'Pregunta ${index + 1}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  correct ? 'Respuesta correcta' : 'Respuesta incorrecta',
                                  style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.75)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Pts', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              Text('$points', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: statusColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: onDone,
                icon: const Icon(Icons.library_books),
                label: const Text('Volver a la biblioteca', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatChip({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
      backgroundColor: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: color.withOpacity(0.15))),
    );
  }
}
