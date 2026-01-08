import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';

class ReportCardWidget extends StatelessWidget {
  final Results result;
  final VoidCallback onTap;

  const ReportCardWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar color e ícono según tipo de juego
    final isMultiplayer = result.gameType == GameType.multiplayer;
    final iconColor = isMultiplayer ? Colors.purple : Colors.blue;
    final icon = isMultiplayer ? Icons.groups : Icons.person;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. Ícono / Distintivo del tipo de juego
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),

              // 2. Información Principal (Título y Fecha)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result.completationDateFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Etiqueta de tipo de juego
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result.gameType.name, // "Singleplayer" o "Multiplayer"
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Métricas (Puntaje y Ranking)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${result.finalScore} pts",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Color de éxito para puntaje
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (result.rankingPosition != null)
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "Puesto #${result.rankingPosition}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      "Solitario",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:frontkahoot2526/features/library/reports/domain/results.dart';
// import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart'; // Importa tus colores

// class ReportCardWidget extends StatelessWidget {
//   final Results result;
//   final VoidCallback onTap;

//   const ReportCardWidget({
//     super.key,
//     required this.result,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 1. Formatear datos
//     final dateFormatted = DateFormat('dd MMM yyyy', 'es').format(result.completionDate);
//     final isMultiplayer = result.gameType == GameType.Multiplayer;
    
//     // Colores para el ícono distintivo
//     final typeIcon = isMultiplayer ? Icons.groups : Icons.person;
//     final typeColor = isMultiplayer ? Colors.purple : Colors.blue;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         // Altura fija similar a QuizCard, quizás un poco menos alta porque no hay imagen grande
//         height: 100, 
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           // REPLICANDO TU ESTILO DE QUIZCARD:
//           color: AppColors.orangeAccent.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: const Color.fromARGB(255, 86, 81, 81).withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             // --- 1. IZQUIERDA: Ícono de Tipo de Juego (En vez de Imagen) ---
//             Container(
//               width: 80, // Ancho fijo para la zona izquierda
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.3), // Fondo sutil para el icono
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   bottomLeft: Radius.circular(16),
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(typeIcon, color: typeColor, size: 32),
//                   const SizedBox(height: 4),
//                   Text(
//                     result.gameType.name,
//                     style: TextStyle(
//                       fontSize: 10, 
//                       fontWeight: FontWeight.bold,
//                       color: typeColor
//                     ),
//                     textAlign: TextAlign.center,
//                   )
//                 ],
//               ),
//             ),

//             // --- 2. CENTRO: Información del Quiz ---
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       result.title,
//                       style: TextStyle(
//                         color: AppColors.darkBlueText,
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         Icon(Icons.calendar_today, size: 12, color: AppColors.darkBlueText.withOpacity(0.6)),
//                         const SizedBox(width: 4),
//                         Text(
//                           dateFormatted,
//                           style: TextStyle(
//                             color: AppColors.darkBlueText.withOpacity(0.8),
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // --- 3. DERECHA: Puntaje y Ranking ---
//             Container(
//               padding: const EdgeInsets.only(right: 16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     "${result.finalScore}",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.green, // Destacar el puntaje
//                     ),
//                   ),
//                   const Text(
//                     "puntos",
//                     style: TextStyle(fontSize: 10, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
                  
//                   // Ranking (si aplica)
//                   if (result.rankingPosition != null)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.amber.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.emoji_events, size: 12, color: Colors.amber),
//                           const SizedBox(width: 4),
//                           Text(
//                             "#${result.rankingPosition}",
//                             style: TextStyle(
//                               fontSize: 12, 
//                               fontWeight: FontWeight.bold,
//                               color: Colors.amber[900]
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }