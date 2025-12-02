import 'package:flutter/material.dart';
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
            height: 100,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 114, 224, 223),
              //color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // --- 1. IMAGEN (Izquierda) ---
                Container(
                  width: 100,
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

                          // child: Container(
                          //   color: Colors.grey[200],
                          // ), // Tu imagen iría aquí
                        ),
                      ),
                      //  Aquí iba el total de preguntas del quiz
                      // Positioned(
                      //   bottom: 4,
                      //   right: 4,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 8,
                      //       vertical: 4,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       //color: theme.colorScheme.primary,
                      //       color: Colors.yellow[700],
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: Text(
                      //       quiz.questionCount,
                      //       style: const TextStyle(
                      //         color: Colors.black,
                      //         fontSize: 10,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(
                              height: 6,
                            ), // Pequeña separación vertical
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
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Autor: ${quiz.authorName!}",
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.w600, // Semi-bold
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
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    quiz.visibilityText!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
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

// class QuizCard extends StatelessWidget {
//   final QuizCardUiModel quiz;

//   const QuizCard({super.key, required this.quiz});

//   @override
//   Widget build(BuildContext context) {
//     //final theme = Theme.of(context);

//     return Container(
//       height: 100,
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 114, 224, 223),
//         //color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           // --- 1. IMAGEN (Izquierda) ---
//           Container(
//             width: 100,
//             margin: const EdgeInsets.all(8),
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       color: Colors.grey[200],
//                     ), // Tu imagen iría aquí
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 4,
//                   right: 4,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       //color: theme.colorScheme.primary,
//                       color: Colors.yellow[700],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       quiz.questionCount,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // --- 2. INFO (Derecha) ---
//           Expanded(
//             //Expanded para que ocupe todo el espacio sobrante
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     quiz.title,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     //style: theme.textTheme.titleMedium,
//                   ),

//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Fila 1: Fecha • Jugadas
//                       Text(
//                         // Usamos un caracter "bullet" (•) para separar
//                         "${quiz.dateInfo} • ${quiz.playCount}",
//                         style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       const SizedBox(height: 6), // Pequeña separación vertical
//                       // Fila 2: Autor O Visibilidad (Dependiendo del caso)
//                       if (quiz.authorName != null)
//                         // Caso Favoritos: Muestra Avatar + Nombre
//                         Row(
//                           children: [
//                             // Avatar circular pequeño (Estilo Kahoot)
//                             // CircleAvatar(
//                             //   radius: 8,
//                             //   backgroundColor: Colors.grey[300], // Fondo placeholder
//                             //   child: const Icon(Icons.person, size: 12, color: Colors.grey),
//                             // ),
//                             const SizedBox(width: 6),
//                             Expanded(
//                               child: Text(
//                                 "Autor: ${quiz.authorName!}",
//                                 style: TextStyle(
//                                   color: Colors.grey[800],
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600, // Semi-bold
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       if (quiz.visibilityText != null)
//                         Row(
//                           children: [
//                             Icon(
//                               quiz.visibilityIcon,
//                               size: 16,
//                               color: Colors.grey[600],
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               quiz.visibilityText!,
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
