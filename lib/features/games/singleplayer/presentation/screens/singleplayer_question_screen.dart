import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/common/timer.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class SingleplayerQuestionScreen extends StatefulWidget {
  final Map<String, dynamic> slide;
  final int currentScore;
  final void Function(int answerIndex, int timeElapsedMs) onAnswer;

  const SingleplayerQuestionScreen({super.key, required this.slide, required this.currentScore, required this.onAnswer});

  @override
  State<SingleplayerQuestionScreen> createState() => _SingleplayerQuestionScreenState();
}

class _SingleplayerQuestionScreenState extends State<SingleplayerQuestionScreen> {
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  void _handleAnswer(int index) {
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    widget.onAnswer(index, elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;
    final options = (slide['options'] as List).cast<Map<String, dynamic>>();

    // Ensure we have up to 4 options (pad if necessary)
    final padded = List<Map<String, dynamic>>.from(options);
    while (padded.length < 4) {
      padded.add({'index': padded.length, 'text': '---'});
    }

    final List<Color> optionColors = [
      Colors.red,
      Colors.blue,
      Colors.amber,
      Colors.green,
    ];

    final List<IconData> optionIcons = [
      Icons.change_history,
      Icons.crop_square,
      Icons.circle,
      Icons.star,
    ];

    return Column(
      children: [
        // Timer en la esquina superior derecha (sin encabezado de "Pregunta")
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: GameTimerWidget(totalSeconds: (slide['timeLimitSeconds'] as int?) ?? 20),
          ),
        ),

        // Imagen y texto de la pregunta
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                if (slide['mediaUrl'] != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        slide['mediaUrl'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                Text(
                  slide['questionText'] as String? ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlueText, height: 1.2),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Sección de respuestas (grid 2x2) - square buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: padded.length,
              itemBuilder: (context, index) {
                final opt = padded[index];
                final color = optionColors[index % optionColors.length];
                final icon = optionIcons[index % optionIcons.length];

                return _AnswerButton(
                  text: opt['text'] as String? ?? '',
                  color: color,
                  icon: icon,
                  onTap: () => _handleAnswer(opt['index'] as int),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Widget para las respuestas (estilo multiplayer)
class _AnswerButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AnswerButton({required this.text, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
