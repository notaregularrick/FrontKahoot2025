import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';

class QuizCard extends StatelessWidget {
  final QuizCardUiModel quiz;
  final VoidCallback onTap;

  const QuizCard({super.key, required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.orangeAccent.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(255, 86, 81, 81).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // --- 1. IMAGEN (Izquierda) ---
                Container(
                  width: 120,
                  margin: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            quiz.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 2. INFO (Derecha) ---
                Expanded(
                  //Expanded para que ocupe todo el espacio sobrante
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          quiz.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.darkBlueText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          //style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          "Categoría: ${quiz.category}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.darkBlueText.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          //style: theme.textTheme.titleMedium,
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila 1: Fecha • Jugadas
                            Text(
                              // Usamos un caracter "bullet" (•) para separar
                              "${quiz.dateInfo} • ${quiz.playCount}",
                              style: TextStyle(
                                color: AppColors.darkBlueText.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // const SizedBox(
                            //   height: 6,
                            // ), // Pequeña separación vertical
                            // Fila 2: Autor O Visibilidad (Dependiendo del caso)
                            if (quiz.authorName != null)
                              // Caso Favoritos: Muestra Avatar + Nombre
                              Row(
                                children: [
                                  // Avatar circular pequeño (Estilo Kahoot)
                                  // CircleAvatar(
                                  //   radius: 8,
                                  //   backgroundColor: Colors.grey[300], // Fondo placeholder
                                  //   child: const Icon(Icons.person, size: 12, color: Colors.grey),
                                  // ),
                                  Expanded(
                                    child: Text(
                                      "Autor: ${quiz.authorName!}",
                                      style: TextStyle(
                                        color: AppColors.darkBlueText
                                            .withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (quiz.visibilityText != null)
                              Row(
                                children: [
                                  Icon(
                                    quiz.visibilityIcon,
                                    size: 13,
                                    color: AppColors.darkBlueText.withOpacity(
                                      0.9,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "${quiz.visibilityText!} • ${quiz.status}",
                                    style: TextStyle(
                                      color: AppColors.darkBlueText.withOpacity(
                                        0.9,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
