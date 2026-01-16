import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class HostQuestionView extends StatefulWidget {
  final CurrentQuestion question;
  final int totalPlayers;
  final VoidCallback onTimeout;

  const HostQuestionView({
    super.key,
    required this.question,
    required this.totalPlayers,
    required this.onTimeout,
  });

  @override
  State<HostQuestionView> createState() => _HostQuestionViewState();
}

class _HostQuestionViewState extends State<HostQuestionView> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.question.timeLimitSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          widget.onTimeout();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calcular el progreso de respuestas
    final int answeredCount = widget.question.numberOfSubmissions ?? 0;
    final double answerProgress = widget.totalPlayers > 0
        ? answeredCount / widget.totalPlayers
        : 0.0;

    // 2. LÓGICA DE COLOR (Igual que GameTimerWidget)
    // Calculamos el porcentaje de tiempo restante (de 1.0 a 0.0)
    double timePercentage = 0.0;
    if (widget.question.timeLimitSeconds > 0) {
      timePercentage = _remainingSeconds / widget.question.timeLimitSeconds;
    }

    Color timerColor = Colors.green; // Por defecto verde
    if (timePercentage < 0.6)
      timerColor = Colors.orange; // Menos del 60%: Naranja
    if (timePercentage < 0.3) timerColor = Colors.red; // Menos del 30%: Rojo

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    "Pregunta ${widget.question.questionIndex + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                ),

                // --- TIMER CON COLOR DINÁMICO ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: timerColor.withOpacity(
                      0.1,
                    ), // Fondo suave del mismo color
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: timerColor,
                      width: 2,
                    ), // Borde del color
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: timerColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "$_remainingSeconds s",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: timerColor, // Texto del color
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- IMAGEN ---
            if (widget.question.questionImageUrl.isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.question.questionImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),

            // --- TEXTO PREGUNTA ---
            Text(
              widget.question.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 20),

            // --- CONTADOR RESPUESTAS ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkBlueText,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBlueText.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Respuestas recibidas",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$answeredCount",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        " / ${widget.totalPlayers}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: answerProgress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- RESPUESTAS ---
            _buildAnswerGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerGrid() {
    if (widget.question.type == QuestionType.trueFalse) {
      return SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _HostAnswerCard(
                index: 0,
                text: "Verdadero",
                color: Colors.blue,
                icon: Icons.check,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HostAnswerCard(
                index: 1,
                text: "Falso",
                color: Colors.red,
                icon: Icons.close,
              ),
            ),
          ],
        ),
      );
    }

    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      const Color(0xFFD69E00),
      Colors.green,
    ];
    final List<IconData> icons = [
      Icons.change_history,
      Icons.crop_square_outlined,
      Icons.circle,
      Icons.square,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: widget.question.options.length,
      itemBuilder: (context, index) {
        final option = widget.question.options[index];
        return _HostAnswerCard(
          index: index,
          text: option.answerText ?? "",
          imageUrl: option.answerImageUrl,
          color: colors[index % colors.length],
          icon: icons[index % icons.length],
        );
      },
    );
  }
}

class _HostAnswerCard extends StatelessWidget {
  final int index;
  final String text;
  final String? imageUrl;
  final Color color;
  final IconData icon;

  const _HostAnswerCard({
    required this.index,
    required this.text,
    this.imageUrl,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            if (hasImage)
              Positioned.fill(
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  color: Colors.black26,
                  colorBlendMode: BlendMode.darken,
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
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error, color: Colors.white)),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              left: 6,
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

// class HostQuestionView extends StatefulWidget {
//   final CurrentQuestion question;
//   final int totalPlayers;
//   final VoidCallback onTimeout;

//   const HostQuestionView({
//     super.key,
//     required this.question,
//     required this.totalPlayers,
//     required this.onTimeout,
//   });

//   @override
//   State<HostQuestionView> createState() => _HostQuestionViewState();
// }

// class _HostQuestionViewState extends State<HostQuestionView> {
//   late Timer _timer;
//   late int _remainingSeconds;

//   @override
//   void initState() {
//     super.initState();
//     _remainingSeconds = widget.question.timeLimitSeconds;
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) return;

//       setState(() {
//         if (_remainingSeconds > 0) {
//           _remainingSeconds--;
//         } else {
//           //Tiempo acabado
//           _timer.cancel();
//           widget.onTimeout(); //Siguiente fase
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer
//         .cancel(); //timer reiniciado si se cambia manual
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //  progreso de respuestas
//     final int answeredCount = widget.question.numberOfSubmissions ?? 0;
//     final double progress = widget.totalPlayers > 0
//         ? answeredCount / widget.totalPlayers
//         : 0.0;

//     // Color del timer 
//     final timerColor = _remainingSeconds <= 5
//         ? Colors.red
//         : AppColors.primaryRed;

//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
            
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: const [
//                       BoxShadow(color: Colors.black12, blurRadius: 4),
//                     ],
//                   ),
//                   child: Text(
//                     "Pregunta ${widget.question.questionIndex + 1}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.darkBlueText,
//                     ),
//                   ),
//                 ),

//                 // Timer
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: timerColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: timerColor, width: 2),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.timer_outlined, color: timerColor, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         "$_remainingSeconds s",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w900,
//                           color: timerColor,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // 2. IMAGEN
//             if (widget.question.questionImageUrl.isNotEmpty)
//               Container(
//                 height: 150,
//                 width: double.infinity,
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: const [
//                     BoxShadow(color: Colors.black12, blurRadius: 8),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     widget.question.questionImageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => const SizedBox(),
//                   ),
//                 ),
//               ),

//             //Texto de pregunta
//             Text(
//               widget.question.questionText,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.darkBlueText,
//                 height: 1.2,
//               ),
//             ),

//             const SizedBox(height: 20),

//             //Cantidad de respuestas
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               decoration: BoxDecoration(
//                 color: AppColors.darkBlueText,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.darkBlueText.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Respuestas recibidas",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.baseline,
//                     textBaseline: TextBaseline.alphabetic,
//                     children: [
//                       Text(
//                         "$answeredCount",
//                         style: const TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.w900,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Text(
//                         " / ${widget.totalPlayers}",
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white54,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4),
//                     child: LinearProgressIndicator(
//                       value: progress,
//                       backgroundColor: Colors.white24,
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                         Colors.greenAccent,
//                       ),
//                       minHeight: 6,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // 5. GRILLA DE RESPUESTAS (Visual)
//             _buildAnswerGrid(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnswerGrid() {
//     if (widget.question.type == QuestionType.trueFalse) {
//       return Row(
//         children: [
//           Expanded(
//             child: _HostAnswerCard(
//               index: 0,
//               text: "Verdadero",
//               color: Colors.blue,
//               icon: Icons.check,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: _HostAnswerCard(
//               index: 1,
//               text: "Falso",
//               color: Colors.red,
//               icon: Icons.close,
//             ),
//           ),
//         ],
//       );
//     }

//     final List<Color> colors = [
//       Colors.red,
//       Colors.blue,
//       const Color(0xFFD69E00),
//       Colors.green,
//     ];
//     final List<IconData> icons = [
//       Icons.change_history,
//       Icons.crop_square_outlined,
//       Icons.circle,
//       Icons.square,
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 1.8,
//       ),
//       itemCount: widget.question.options.length,
//       itemBuilder: (context, index) {
//         final option = widget.question.options[index];
//         return _HostAnswerCard(
//           index: index,
//           text: option.answerText ?? "",
//           imageUrl: option.answerImageUrl,
//           color: colors[index % colors.length],
//           icon: icons[index % icons.length],
//         );
//       },
//     );
//   }
// }

// class _HostAnswerCard extends StatelessWidget {
//   final int index;
//   final String text;
//   final String? imageUrl;
//   final Color color;
//   final IconData icon;

//   const _HostAnswerCard({
//     required this.index,
//     required this.text,
//     this.imageUrl,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Stack(
//           children: [
//             if (hasImage)
//               Positioned.fill(
//                 child: Image.network(
//                   imageUrl!,
//                   fit: BoxFit.cover,
//                   color: Colors.black26,
//                   colorBlendMode: BlendMode.darken,
//                 ),
//               )
//             else
//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Text(
//                     text,
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
//             Positioned(
//               top: 6,
//               left: 6,
//               child: Icon(icon, color: Colors.white70, size: 20),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
