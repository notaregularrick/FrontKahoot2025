import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
import 'package:frontkahoot2526/features/library/reports/domain/personal_question_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/personal_result.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/providers/report_use_case_providers.dart';

class PersonalResultsScreen extends ConsumerWidget {
  final String gameId;
  final GameType gameType;
  const PersonalResultsScreen({
    super.key,
    required this.gameId,
    required this.gameType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(
      personalResultsProvider((gameId: gameId, gameType: gameType)),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Resultados Personales',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: resultsAsync.when(
        error: (err, stack) => Text("Error: $err"),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (data) {
          return Column(
            children: [
              //Encabezado
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildHeader(data),
              ),

              //Resumen de Estadísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSummaryCard(data),
              ),

              const SizedBox(height: 16),

              //Título de la sección de lista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Desglose de Preguntas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //Lista de Preguntas
              Expanded(child: _buildQuestionsList(data.questionResults)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(PersonalResult data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlueText,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Row(
          //   children: [
          //     const Icon(Icons.person, color: Colors.white70, size: 16),
          //     const SizedBox(width: 8),
          //     Text(
          //       "Jugador ID: ${data.userId}", // O Nombre si lo tuvieras
          //       style: const TextStyle(color: Colors.white70, fontSize: 14),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PersonalResult data) {
    final double accuracy = data.totalQuestions > 0
        ? data.correctAnswers / data.totalQuestions
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.creamBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Puntuación
          _buildStatItem(
            label: "Puntos",
            value: "${data.finalScore}",
            icon: Icons.emoji_events,
            color: AppColors.mustardYellow,
          ),

          // Barra de Presición
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: accuracy,
                      backgroundColor: Colors.white,
                      color: accuracy > 0.5 ? Colors.green : Colors.orange,
                      strokeWidth: 5,
                    ),
                  ),
                  Text(
                    "${data.correctAnswers}/${data.totalQuestions}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Aciertos",
                style: TextStyle(fontSize: 16, color: AppColors.darkBlueText),
              ),
            ],
          ),

          // Tiempo Promedio
          _buildStatItem(
            label: "Tiempo Avg",
            value: "${(data.averageTimeMs / 1000).toStringAsFixed(1)}s",
            icon: Icons.timer,
            color: Colors.blue,
          ),

          // Posición (si es multijugador)
          if (data.rankingPosition != null)
            _buildStatItem(
              label: "Posición",
              value: "#${data.rankingPosition}",
              icon: Icons.leaderboard,
              color: Colors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppColors.darkBlueText),
        ),
      ],
    );
  }

  Widget _buildQuestionsList(List<PersonalQuestionResult> questions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final q = questions[index];
        final Color statusColor = q.isCorrect ? Colors.green : Colors.red;
        final Color bgColor = q.isCorrect
            ? Colors.green.shade100
            : Colors.red.shade100;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.orangeAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pregunta ${q.questionIndex + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 20, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          "${(q.timeTakenMs / 1000).toStringAsFixed(1)}s",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cuerpo de la tarjeta
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texto de la pregunta
                    Text(
                      q.questionText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // "Texto o Imagen" de la respuesta dada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      // decoration: BoxDecoration(
                      //   //color: Colors.grey.shade50,
                      //   borderRadius: BorderRadius.circular(8),
                      //   border: Border.all(color: Colors.grey.shade200),
                      // ),
                      child: _buildAnswerContent(q),
                    ),

                    const SizedBox(height: 10),

                    // Pie: Correcto / Incorrecto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          q.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          q.isCorrect ? "Correcto" : "Incorrecto",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Lógica para decidir qué mostrar (Texto o Imagen)
  Widget _buildAnswerContent(PersonalQuestionResult q) {
    // 1. Si hay imágenes (Media ID)
    // if (q.answerMediaId.isNotEmpty) {
    //   return Column(
    //     children: [
    //       const Icon(Icons.image, size: 40, color: Colors.grey),
    //       const SizedBox(height: 4),
    //       Text(
    //         "Imagen Seleccionada",
    //         style: TextStyle(
    //           color: Colors.grey.shade600,
    //           fontStyle: FontStyle.italic,
    //         ),
    //       ),
    //       // Aquí podrías usar un Image.network si tienes la URL basada en el ID
    //     ],
    //   );
    // }

    if (q.answerMediaId.isNotEmpty) {
      return Column(
        children: q.answerMediaId.map((url) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(4), // Padding mínimo para el borde
            decoration: BoxDecoration(
              color: Colors.grey[200], 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade500),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                url,
                height: 120,
                width: double.infinity,
                fit: BoxFit.contain,

                // CARGANDO
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },

                // ERROR
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey.shade100, // Solo gris si falla
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "No disponible",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      );
    }

    // 2. Si hay texto
    if (q.answerText.isNotEmpty) {
      return Column(
        children: q.answerText.map((text) {
          return Container(
            width: double.infinity, // Ocupa todo el ancho
            margin: const EdgeInsets.only(
              bottom: 8,
            ), // Espacio entre respuestas
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade500),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          );
        }).toList(),
      );
    }
    // if (q.answerText.isNotEmpty) {
    //   return Text(
    //     q.answerText.join(", "), // Une respuestas múltiples si las hay
    //     textAlign: TextAlign.center,
    //     style: const TextStyle(
    //       fontSize: 15,
    //       color: Colors.black87,
    //     ),
    //   );
    // }

    // 3. Sin respuesta
    return Text(
      "Sin respuesta",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
