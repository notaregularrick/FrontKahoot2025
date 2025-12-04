import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/common/timer.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class PlayerQuestionView extends StatelessWidget {
  final CurrentQuestion question;
  final Function(int) onAnswer;
  final bool isLoading;
  final int timeElapsed;

  const PlayerQuestionView({
    super.key,
    required this.question,
    required this.onAnswer,
    this.isLoading = false,
    this.timeElapsed = 0,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> optionColors = [
      Colors.red, // Triángulo
      Colors.blue, // Rombo
      Colors.amber, // Círculo
      Colors.green, // Cuadrado
    ];

    final List<IconData> optionIcons = [
      Icons.change_history,
      Icons.crop_square,
      Icons.circle,
      Icons.star,
    ];

    return Column(
      children: [
        //Pregunta actual y timer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Pregunta
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Text(
                  "Pregunta ${question.questionIndex}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueText,
                  ),
                ),
              ),
              //Timer
              GameTimerWidget(totalSeconds: question.timeLimitSeconds),
            ],
          ),
        ),

        //Imagen y la pregunta
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Imagen
                if (question.questionImageUrl != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        question.questionImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Texto de la Pregunta
                Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        //Sección de respuestas
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final color = optionColors[index % optionColors.length];
                  final icon = optionIcons[index % optionIcons.length];

                  return _AnswerButton(
                    text: option.answerText,
                    color: color,
                    icon: icon,
                    onTap: () => onAnswer(index),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

//Widget para las respuestas
class _AnswerButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.onTap,
  });

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
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
