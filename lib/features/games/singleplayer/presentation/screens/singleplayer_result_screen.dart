import 'package:flutter/material.dart';

class SingleplayerResultScreen extends StatelessWidget {
  final int score;
  final List<Map<String, dynamic>> answers;
  final VoidCallback onDone;

  const SingleplayerResultScreen({
    super.key,
    required this.score,
    required this.answers,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final correctCount = answers.where((a) => a['correct'] == true).length;
    final wrongCount = answers.length - correctCount;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text('¡Juego completado!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Puntaje final: $score', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Correctas: $correctCount   Incorrectas: $wrongCount', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: answers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = answers[index];
                final correct = item['correct'] as bool? ?? false;
                return ListTile(
                  leading: Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red),
                  title: Text(item['questionText'] as String? ?? 'Pregunta ${index + 1}'),
                  subtitle: Text(correct ? 'Respuesta correcta' : 'Respuesta incorrecta'),
                  trailing: Text('${item['pointsGained'] ?? 0} pts'),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          ElevatedButton(onPressed: onDone, child: const Text('Volver a la biblioteca')),
        ],
      ),
    );
  }
}
