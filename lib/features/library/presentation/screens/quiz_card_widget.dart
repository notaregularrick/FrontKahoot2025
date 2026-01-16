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
            height: 170,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.softPink,
                  AppColors.cardSurface,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
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
                                color: AppColors.softPink,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.photo_library_outlined,
                                        color: Colors.grey, size: 28),
                                    SizedBox(height: 6),
                                    Text(
                                      'Sin portada',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                quiz.visibilityIcon ?? Icons.auto_awesome,
                                size: 14,
                                color: AppColors.primaryRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                quiz.status,
                                style: TextStyle(
                                  color: AppColors.darkBlueText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: AppColors.primaryRed,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                quiz.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.darkBlueText.withOpacity(
                                    0.9,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 15,
                                  color: AppColors.darkBlueText.withOpacity(
                                    0.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    quiz.dateInfo,
                                    style: TextStyle(
                                      color:
                                          AppColors.darkBlueText.withOpacity(
                                        0.9,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 15,
                                  color: AppColors.darkBlueText.withOpacity(
                                    0.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    quiz.playCount,
                                    style: TextStyle(
                                      color:
                                          AppColors.darkBlueText.withOpacity(
                                        0.9,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                                    color: AppColors.primaryRed,
                                  ),
                                  const SizedBox(width: 4),
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
