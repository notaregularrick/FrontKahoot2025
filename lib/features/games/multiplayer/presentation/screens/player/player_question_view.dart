import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/common/timer.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class PlayerQuestionView extends StatefulWidget {
  final CurrentQuestion question;
  final Function(List<int>) onAnswer;
  final bool isLoading;

  const PlayerQuestionView({
    super.key,
    required this.question,
    required this.onAnswer,
    this.isLoading = false,
  });

  @override
  State<PlayerQuestionView> createState() => _PlayerQuestionViewState();
}

class _PlayerQuestionViewState extends State<PlayerQuestionView> {
  bool _isTimeUp = false;
  Timer? _localTimer;
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _startLocalTimer();
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    super.dispose();
  }

  void _startLocalTimer() {
    _localTimer = Timer(
      Duration(seconds: widget.question.timeLimitSeconds),
      () {
        if (mounted) setState(() => _isTimeUp = true);
      },
    );
  }

  void _handleOptionTap(int index) {
    if (_isTimeUp || widget.isLoading) return;

    if (widget.question.type == QuestionType.multipleChoice) {
      setState(() {
        if (_selectedIndexes.contains(index)) {
          _selectedIndexes.remove(index);
        } else {
          _selectedIndexes.add(index);
        }
      });
    } else {
      widget.onAnswer([index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiple = widget.question.type == QuestionType.multipleChoice;
    // Padding extra al fondo si hay botón flotante para que no tape las respuestas
    final bottomContentPadding = isMultiple ? 100.0 : 30.0;

    return Stack(
      children: [
        Column(
          children: [
            // --- 1. HEADER FIJO (Pregunta # y Reloj) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      "Pregunta ${widget.question.questionIndex + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                  ),
                  GameTimerWidget(
                    totalSeconds: widget.question.timeLimitSeconds,
                  ),
                ],
              ),
            ),

            // --- 2. CUERPO UNIFICADO (Pregunta + Respuestas Juntas) ---
            Expanded(
              child: Center(
                // Centra todo el bloque verticalmente
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomContentPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Ocupa solo lo necesario
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // A. IMAGEN (Opcional)
                      if (widget.question.questionImageUrl.isNotEmpty)
                        Container(
                          height: 180,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 8),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              widget.question.questionImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                        ),

                      // B. TEXTO DE PREGUNTA
                      Text(
                        widget.question.questionText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                          height: 1.2,
                        ),
                      ),

                      // Indicador de Múltiple
                      if (isMultiple)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Chip(
                            label: const Text("Selección Múltiple"),
                            backgroundColor: Colors.orange.withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            side: BorderSide.none,
                          ),
                        ),

                      // C. ESPACIO CONTROLADO (Aquí está la magia)
                      // Este SizedBox define la distancia exacta entre el texto y las respuestas.
                      const SizedBox(height: 32),

                      // D. RESPUESTAS (Dentro del mismo scroll)
                      widget.isLoading
                          ? const CircularProgressIndicator()
                          : _buildAnswerLayout(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // --- 3. BOTÓN FLOTANTE (Solo Múltiple) ---
        if (isMultiple && !widget.isLoading && !_isTimeUp)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _selectedIndexes.isNotEmpty
                  ? () => widget.onAnswer(_selectedIndexes.toList())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "ENVIAR RESPUESTA",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        // --- 4. OVERLAY TIEMPO AGOTADO ---
        if (_isTimeUp)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: SingleChildScrollView(
                  // Evita overflow si la pantalla es muy chica
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_off_outlined,
                        color: Colors.white,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "¡Se acabó el tiempo!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Espera a que el anfitrión avance.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- MÉTODOS DE LAYOUT DE RESPUESTAS (Idénticos al anterior, solo optimizados) ---

  Widget _buildAnswerLayout() {
    if (widget.question.type == QuestionType.trueFalse) {
      return _buildTrueFalseLayout();
    } else {
      return _buildStandardGrid();
    }
  }

  Widget _buildTrueFalseLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Importante para que no estire de más
      children: [
        SizedBox(
          height: 120, // Altura fija y cómoda
          width: double.infinity,
          child: _AnswerCard(
            option: widget.question.options.isNotEmpty
                ? widget.question.options[0]
                : null,
            index: 0,
            color: Colors.blue,
            icon: Icons.check_rounded,
            labelOverride: "Verdadero",
            isSelected: _selectedIndexes.contains(0),
            onTap: () => _handleOptionTap(0),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: _AnswerCard(
            option: widget.question.options.length > 1
                ? widget.question.options[1]
                : null,
            index: 1,
            color: Colors.red,
            icon: Icons.close_rounded,
            labelOverride: "Falso",
            isSelected: _selectedIndexes.contains(1),
            onTap: () => _handleOptionTap(1),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardGrid() {
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

    // GridView dentro de Column necesita shrinkWrap: true y NoScroll
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: widget.question.options.length,
      itemBuilder: (context, index) {
        return _AnswerCard(
          option: widget.question.options[index],
          index: index,
          color: colors[index % colors.length],
          icon: icons[index % icons.length],
          isSelected: _selectedIndexes.contains(index),
          onTap: () => _handleOptionTap(index),
        );
      },
    );
  }
}

// --- CLASE _AnswerCard (Sin cambios, solo copia la del paso anterior) ---
class _AnswerCard extends StatelessWidget {
  final QuestionAnswers? option;
  final int index;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final String? labelOverride;
  final bool isSelected;

  const _AnswerCard({
    required this.option,
    required this.index,
    required this.color,
    required this.icon,
    required this.onTap,
    this.labelOverride,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        option?.answerImageUrl != null && option!.answerImageUrl!.isNotEmpty;
    final textToShow = labelOverride ?? option?.answerText ?? "";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.darkBlueText, width: 5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.3 : 0.1),
            blurRadius: isSelected ? 8 : 4,
            offset: Offset(0, isSelected ? 2 : 4),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(isSelected ? 7 : 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: hasImage
                    ? _buildImageContent(option!.answerImageUrl!, icon)
                    : _buildTextContent(textToShow, icon),
              ),
              if (isSelected)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(String text, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 24),
        ),
        Expanded(
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(String url, IconData icon) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.error, color: Colors.white)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black38, Colors.transparent],
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ],
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:frontkahoot2526/features/games/common/timer.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

// class PlayerQuestionView extends StatefulWidget {
//   final CurrentQuestion question;
//   // ⚠️ CAMBIO IMPORTANTE: Ahora devuelve una Lista de enteros
//   final Function(List<int>) onAnswer;
//   final bool isLoading;

//   const PlayerQuestionView({
//     super.key,
//     required this.question,
//     required this.onAnswer,
//     this.isLoading = false,
//   });

//   @override
//   State<PlayerQuestionView> createState() => _PlayerQuestionViewState();
// }

// class _PlayerQuestionViewState extends State<PlayerQuestionView> {
//   bool _isTimeUp = false;
//   Timer? _localTimer;

//   // ✅ NUEVO: Para guardar múltiples selecciones localmente
//   final Set<int> _selectedIndexes = {};

//   @override
//   void initState() {
//     super.initState();
//     _startLocalTimer();
//   }

//   @override
//   void dispose() {
//     _localTimer?.cancel();
//     super.dispose();
//   }

//   void _startLocalTimer() {
//     _localTimer = Timer(
//       Duration(seconds: widget.question.timeLimitSeconds),
//       () {
//         if (mounted) {
//           setState(() => _isTimeUp = true);
//         }
//       },
//     );
//   }

//   void _handleOptionTap(int index) {
//     if (_isTimeUp || widget.isLoading) return;

//     // LÓGICA DE SELECCIÓN
//     if (widget.question.type == QuestionType.multipleChoice) {
//       // Si es múltiple, solo marcamos/desmarcamos visualmente
//       setState(() {
//         if (_selectedIndexes.contains(index)) {
//           _selectedIndexes.remove(index);
//         } else {
//           _selectedIndexes.add(index);
//         }
//       });
//     } else {
//       // Si es Single o True/False, enviamos de una vez (como lista de 1 elemento)
//       widget.onAnswer([index]);
//     }
//   }

//   void _submitMultipleAnswers() {
//     if (_isTimeUp || widget.isLoading) return;
//     if (_selectedIndexes.isNotEmpty) {
//       widget.onAnswer(_selectedIndexes.toList());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Column(
//           children: [
//             // --- HEADER ---
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(color: Colors.black12, blurRadius: 4),
//                       ],
//                     ),
//                     child: Text(
//                       "Pregunta ${widget.question.questionIndex + 1}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.darkBlueText,
//                       ),
//                     ),
//                   ),
//                   GameTimerWidget(
//                     totalSeconds: widget.question.timeLimitSeconds,
//                   ),
//                 ],
//               ),
//             ),

//             // --- BODY ---
//             Expanded(
//               flex: 4,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (widget.question.questionImageUrl.isNotEmpty)
//                       Container(
//                         height: 180,
//                         width: double.infinity,
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(color: Colors.black12, blurRadius: 8),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child: Image.network(
//                             widget.question.questionImageUrl,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => const SizedBox(),
//                           ),
//                         ),
//                       ),
//                     Text(
//                       widget.question.questionText,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.darkBlueText,
//                         height: 1.2,
//                       ),
//                     ),
//                     // Indicador visual de que es selección múltiple
//                     if (widget.question.type == QuestionType.multipleChoice)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Chip(
//                           label: const Text("Selección Múltiple"),
//                           backgroundColor: Colors.orange.withOpacity(0.2),
//                           labelStyle: TextStyle(
//                             color: Colors.orange[800],
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // --- FOOTER (Grilla) ---
//             Expanded(
//               flex: 5,
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(
//                   16,
//                   16,
//                   16,
//                   80,
//                 ), // Padding extra abajo para el botón
//                 child: widget.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _buildAnswerLayout(),
//               ),
//             ),
//           ],
//         ),

//         // --- BOTÓN FLOTANTE "ENVIAR" (Solo para Múltiple) ---
//         if (widget.question.type == QuestionType.multipleChoice &&
//             !widget.isLoading &&
//             !_isTimeUp)
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton(
//               onPressed: _selectedIndexes.isNotEmpty
//                   ? _submitMultipleAnswers
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryRed,
//                 disabledBackgroundColor: Colors.grey[300],
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 5,
//               ),
//               child: const Text(
//                 "ENVIAR RESPUESTA",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),

//         // --- OVERLAY TIEMPO AGOTADO ---
//         if (_isTimeUp)
//           Container(
//             color: Colors.black.withOpacity(0.85),
//             width: double.infinity,
//             height: double.infinity,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.timer_off_outlined,
//                   color: Colors.white,
//                   size: 80,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "¡Se acabó el tiempo!",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 const CircularProgressIndicator(color: Colors.white),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAnswerLayout() {
//     if (widget.question.type == QuestionType.trueFalse) {
//       return _buildTrueFalseLayout();
//     } else {
//       return _buildStandardGrid();
//     }
//   }

//   Widget _buildTrueFalseLayout() {
//     return Column(
//       children: [
//         Expanded(
//           child: _AnswerCard(
//             option: widget.question.options.isNotEmpty
//                 ? widget.question.options[0]
//                 : null,
//             index: 0,
//             color: Colors.blue,
//             icon: Icons.check_rounded,
//             labelOverride: "Verdadero",
//             isSelected: _selectedIndexes.contains(0), // ✅
//             onTap: () => _handleOptionTap(0),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: _AnswerCard(
//             option: widget.question.options.length > 1
//                 ? widget.question.options[1]
//                 : null,
//             index: 1,
//             color: Colors.red,
//             icon: Icons.close_rounded,
//             labelOverride: "Falso",
//             isSelected: _selectedIndexes.contains(1), // ✅
//             onTap: () => _handleOptionTap(1),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStandardGrid() {
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
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 1.1,
//       ),
//       itemCount: widget.question.options.length,
//       itemBuilder: (context, index) {
//         return _AnswerCard(
//           option: widget.question.options[index],
//           index: index,
//           color: colors[index % colors.length],
//           icon: icons[index % icons.length],
//           isSelected: _selectedIndexes.contains(
//             index,
//           ), // ✅ Pasamos el estado de selección
//           onTap: () => _handleOptionTap(index),
//         );
//       },
//     );
//   }
// }

// // --- WIDGET TARJETA MODIFICADO PARA SOPORTAR SELECCIÓN VISUAL ---

// class _AnswerCard extends StatelessWidget {
//   final QuestionAnswers? option;
//   final int index;
//   final Color color;
//   final IconData icon;
//   final VoidCallback onTap;
//   final String? labelOverride;
//   final bool isSelected; // ✅ Nuevo parámetro visual

//   const _AnswerCard({
//     required this.option,
//     required this.index,
//     required this.color,
//     required this.icon,
//     required this.onTap,
//     this.labelOverride,
//     this.isSelected = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasImage =
//         option?.answerImageUrl != null && option!.answerImageUrl!.isNotEmpty;
//     final textToShow = labelOverride ?? option?.answerText ?? "";

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         // ✅ EFECTO VISUAL DE SELECCIÓN: Borde grueso y sombra
//         border: isSelected
//             ? Border.all(color: AppColors.darkBlueText, width: 6)
//             : null,
//         boxShadow: isSelected
//             ? [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ]
//             : [
//                 const BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 4,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//       ),
//       child: Material(
//         color: color,
//         borderRadius: BorderRadius.circular(
//           isSelected ? 6 : 12,
//         ), // Ajuste para el borde interno
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: onTap,
//           child: Stack(
//             children: [
//               // Contenido normal
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 child: hasImage
//                     ? _buildImageContent(option!.answerImageUrl!, icon)
//                     : _buildTextContent(textToShow, icon),
//               ),

//               // ✅ Checkmark gigante si está seleccionado (opcional, pero ayuda mucho UX)
//               if (isSelected)
//                 Positioned.fill(
//                   child: Container(
//                     color: Colors.black.withOpacity(0.3), // Oscurece un poco
//                     child: const Center(
//                       child: Icon(
//                         Icons.check_circle,
//                         color: Colors.white,
//                         size: 48,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ... (Los métodos _buildTextContent y _buildImageContent siguen IGUAL que antes) ...
//   // Copia esos métodos del código anterior aquí abajo.

//   Widget _buildTextContent(String text, IconData icon) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Align(
//           alignment: Alignment.topLeft,
//           child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 24),
//         ),
//         Expanded(
//           child: Center(
//             child: Text(
//               text,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black26,
//                     offset: Offset(1, 1),
//                     blurRadius: 2,
//                   ),
//                 ],
//               ),
//               maxLines: 4,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContent(String url, IconData icon) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             url,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) =>
//                 const Center(child: Icon(Icons.error, color: Colors.white)),
//           ),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.black.withOpacity(0.3), Colors.transparent],
//             ),
//           ),
//         ),
//         Positioned(
//           top: 4,
//           left: 4,
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//             child: Icon(icon, color: Colors.white, size: 20),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'dart:async'; // Necesario para el Timer
// import 'package:flutter/material.dart';
// import 'package:frontkahoot2526/features/games/common/timer.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

// // 1. Convertimos a StatefulWidget
// class PlayerQuestionView extends StatefulWidget {
//   final CurrentQuestion question;
//   final Function(int) onAnswer;
//   final bool isLoading;

//   const PlayerQuestionView({
//     super.key,
//     required this.question,
//     required this.onAnswer,
//     this.isLoading = false,
//   });

//   @override
//   State<PlayerQuestionView> createState() => _PlayerQuestionViewState();
// }

// class _PlayerQuestionViewState extends State<PlayerQuestionView> {
//   // Estado local para saber si el tiempo expiró
//   bool _isTimeUp = false;
//   Timer? _localTimer;

//   @override
//   void initState() {
//     super.initState();
//     _startLocalTimer();
//   }

//   @override
//   void dispose() {
//     _localTimer?.cancel(); // Cancelamos timer para evitar memory leaks
//     super.dispose();
//   }

//   void _startLocalTimer() {
//     // Iniciamos un timer que dura lo mismo que la pregunta
//     // Ojo: Le damos un pequeño buffer (ej. 100ms) para que visualmente cuadre con el widget del timer
//     _localTimer = Timer(
//       Duration(seconds: widget.question.timeLimitSeconds),
//       () {
//         if (mounted) {
//           setState(() {
//             _isTimeUp = true;
//           });
//         }
//       },
//     );
//   }

//   void _handleAnswer(int index) {
//     // 2. Protección: Si el tiempo acabó, no hacemos nada
//     if (_isTimeUp || widget.isLoading) return;
//     widget.onAnswer(index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 3. Usamos un Stack para poder poner el mensaje de "Tiempo Agotado" encima de todo
//     return Stack(
//       children: [
//         // CONTENIDO PRINCIPAL (El juego)
//         Column(
//           children: [
//             // --- HEADER (Pregunta y Timer) ---
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(color: Colors.black12, blurRadius: 4),
//                       ],
//                     ),
//                     child: Text(
//                       "Pregunta ${widget.question.questionIndex + 1}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.darkBlueText,
//                       ),
//                     ),
//                   ),
//                   GameTimerWidget(
//                     totalSeconds: widget.question.timeLimitSeconds,
//                   ),
//                 ],
//               ),
//             ),

//             // --- BODY (Imagen opcional y Texto) ---
//             Expanded(
//               flex: 4,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (widget.question.questionImageUrl.isNotEmpty)
//                       Container(
//                         height: 180,
//                         width: double.infinity,
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(color: Colors.black12, blurRadius: 8),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child: Image.network(
//                             widget.question.questionImageUrl,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => const SizedBox(),
//                           ),
//                         ),
//                       ),

//                     Text(
//                       widget.question.questionText,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.darkBlueText,
//                         height: 1.2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // --- FOOTER (Grilla de Respuestas) ---
//             Expanded(
//               flex: 5,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 child: widget.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _buildAnswerLayout(),
//               ),
//             ),
//           ],
//         ),

//         // 4. EL OVERLAY DE TIEMPO AGOTADO
//         if (_isTimeUp)
//           Container(
//             color: Colors.black.withOpacity(
//               0.85,
//             ), // Fondo oscuro semitransparente
//             width: double.infinity,
//             height: double.infinity,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.timer_off_outlined,
//                   color: Colors.white,
//                   size: 80,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "¡Se acabó el tiempo!",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Espera a que el anfitrión avance.",
//                   style: TextStyle(color: Colors.white70, fontSize: 16),
//                 ),
//                 const SizedBox(height: 30),
//                 const CircularProgressIndicator(color: Colors.white),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAnswerLayout() {
//     if (widget.question.type == QuestionType.trueFalse) {
//       return _buildTrueFalseLayout();
//     } else {
//       return _buildStandardGrid();
//     }
//   }

//   Widget _buildTrueFalseLayout() {
//     return Column(
//       children: [
//         Expanded(
//           child: _AnswerCard(
//             option: widget.question.options.length > 0
//                 ? widget.question.options[0]
//                 : null,
//             index: 0,
//             color: Colors.blue,
//             icon: Icons.check_rounded,
//             labelOverride: "Verdadero",
//             // Usamos _handleAnswer en lugar de llamar directo al widget
//             onTap: () => _handleAnswer(0),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: _AnswerCard(
//             option: widget.question.options.length > 1
//                 ? widget.question.options[1]
//                 : null,
//             index: 1,
//             color: Colors.red,
//             icon: Icons.close_rounded,
//             labelOverride: "Falso",
//             onTap: () => _handleAnswer(1),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStandardGrid() {
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
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 1.1,
//       ),
//       itemCount: widget.question.options.length,
//       itemBuilder: (context, index) {
//         final option = widget.question.options[index];

//         return _AnswerCard(
//           option: option,
//           index: index,
//           color: colors[index % colors.length],
//           icon: icons[index % icons.length],
//           onTap: () => _handleAnswer(index),
//         );
//       },
//     );
//   }
// }

// // ... La clase _AnswerCard queda IGUAL que antes, no necesitas tocarla ...
// // Solo asegúrate de copiarla aquí abajo si no la tienes en otro archivo.
// class _AnswerCard extends StatelessWidget {
//   final QuestionAnswers? option;
//   final int index;
//   final Color color;
//   final IconData icon;
//   final VoidCallback onTap;
//   final String? labelOverride;

//   const _AnswerCard({
//     required this.option,
//     required this.index,
//     required this.color,
//     required this.icon,
//     required this.onTap,
//     this.labelOverride,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasImage =
//         option?.answerImageUrl != null && option!.answerImageUrl!.isNotEmpty;
//     final textToShow = labelOverride ?? option?.answerText ?? "";

//     return Material(
//       color: color,
//       borderRadius: BorderRadius.circular(12),
//       elevation: 4,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           child: hasImage
//               ? _buildImageContent(option!.answerImageUrl!, icon)
//               : _buildTextContent(textToShow, icon),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextContent(String text, IconData icon) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Align(
//           alignment: Alignment.topLeft,
//           child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 24),
//         ),
//         Expanded(
//           child: Center(
//             child: Text(
//               text,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black26,
//                     offset: Offset(1, 1),
//                     blurRadius: 2,
//                   ),
//                 ],
//               ),
//               maxLines: 4,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContent(String url, IconData icon) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             url,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) =>
//                 const Center(child: Icon(Icons.error, color: Colors.white)),
//           ),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.black.withOpacity(0.3), Colors.transparent],
//             ),
//           ),
//         ),
//         Positioned(
//           top: 4,
//           left: 4,
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//             child: Icon(icon, color: Colors.white, size: 20),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:frontkahoot2526/features/games/common/timer.dart'; // Asegúrate que este path sea correcto
// import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

// class PlayerQuestionView extends StatelessWidget {
//   final CurrentQuestion question;
//   final Function(int) onAnswer;
//   final bool isLoading;

//   const PlayerQuestionView({
//     super.key,
//     required this.question,
//     required this.onAnswer,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // --- HEADER (Pregunta y Timer) ---
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//                 ),
//                 child: Text(
//                   "Pregunta ${question.questionIndex + 1}", // +1 para que sea humano
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.darkBlueText,
//                   ),
//                 ),
//               ),
//               // Tu widget de Timer existente
//               GameTimerWidget(totalSeconds: question.timeLimitSeconds),
//             ],
//           ),
//         ),

//         // --- BODY (Imagen opcional y Texto) ---
//         Expanded(
//           flex: 4, // Le damos peso para que empuje las respuestas abajo
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Imagen de la PREGUNTA (si existe)
//                 if (question.questionImageUrl.isNotEmpty)
//                   Container(
//                     height: 180,
//                     width: double.infinity,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(color: Colors.black12, blurRadius: 8),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.network(
//                         question.questionImageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => const SizedBox(),
//                       ),
//                     ),
//                   ),

//                 // Texto de la PREGUNTA
//                 Text(
//                   question.questionText,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.darkBlueText,
//                     height: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 10),

//         // --- FOOTER (Grilla de Respuestas Adaptable) ---
//         Expanded(
//           flex: 5, // Área de respuestas
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _buildAnswerLayout(),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Decide qué layout mostrar según el tipo de pregunta
//   Widget _buildAnswerLayout() {
//     if (question.type == QuestionType.trueFalse) {
//       return _buildTrueFalseLayout();
//     } else {
//       return _buildStandardGrid();
//     }
//   }

//   /// Layout específico para Verdadero/Falso (2 botones grandes)
//   Widget _buildTrueFalseLayout() {
//     return Column(
//       children: [
//         Expanded(
//           child: _AnswerCard(
//             option: question.options.length > 0 ? question.options[0] : null,
//             index: 0,
//             color: Colors.blue, // Azul clásico para True
//             icon: Icons.check_rounded, // O un rombo
//             labelOverride: "Verdadero", // Texto forzado si viene vacío
//             onTap: () => onAnswer(0),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Expanded(
//           child: _AnswerCard(
//             option: question.options.length > 1 ? question.options[1] : null,
//             index: 1,
//             color: Colors.red, // Rojo clásico para False
//             icon: Icons.close_rounded, // O un triángulo
//             labelOverride: "Falso",
//             onTap: () => onAnswer(1),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Grilla estándar 2x2 para Multiple Choice o Single Choice
//   Widget _buildStandardGrid() {
//     // Colores clásicos de Kahoot
//     final List<Color> colors = [
//       Colors.red, // 0: Triángulo
//       Colors.blue, // 1: Rombo
//       const Color(
//         0xFFD69E00,
//       ), // 2: Círculo (Amarillo oscurecido para contraste)
//       Colors.green, // 3: Cuadrado
//     ];

//     final List<IconData> icons = [
//       Icons.change_history, // Triángulo
//       Icons.crop_square_outlined, // Rombo (Visualmente similar si se rota)
//       Icons.circle, // Círculo
//       Icons.square, // Cuadrado
//     ];

//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio:
//             1.1, // Ajustar para que sean más cuadrados o rectangulares
//       ),
//       itemCount: question.options.length,
//       itemBuilder: (context, index) {
//         final option = question.options[index];

//         return _AnswerCard(
//           option: option,
//           index: index,
//           color: colors[index % colors.length],
//           icon: icons[index % icons.length],
//           onTap: () => onAnswer(index),
//         );
//       },
//     );
//   }
// }

// // --- WIDGET INDIVIDUAL DE RESPUESTA ---

// class _AnswerCard extends StatelessWidget {
//   final QuestionAnswers? option;
//   final int index;
//   final Color color;
//   final IconData icon;
//   final VoidCallback onTap;
//   final String? labelOverride; // Para T/F si queremos forzar el texto

//   const _AnswerCard({
//     required this.option,
//     required this.index,
//     required this.color,
//     required this.icon,
//     required this.onTap,
//     this.labelOverride,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Determinamos si es imagen o texto
//     final hasImage =
//         option?.answerImageUrl != null && option!.answerImageUrl!.isNotEmpty;
//     final textToShow = labelOverride ?? option?.answerText ?? "";

//     return Material(
//       color: color,
//       borderRadius: BorderRadius.circular(12),
//       elevation: 4,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           child: hasImage
//               ? _buildImageContent(option!.answerImageUrl!, icon)
//               : _buildTextContent(textToShow, icon),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextContent(String text, IconData icon) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Icono de la figura (Triángulo, cuadrado, etc)
//         Align(
//           alignment: Alignment.topLeft,
//           child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 24),
//         ),
//         Expanded(
//           child: Center(
//             child: Text(
//               text,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black26,
//                     offset: Offset(1, 1),
//                     blurRadius: 2,
//                   ),
//                 ],
//               ),
//               maxLines: 4,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContent(String url, IconData icon) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // La Imagen de fondo
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             url,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) =>
//                 const Center(child: Icon(Icons.error, color: Colors.white)),
//           ),
//         ),
//         // Capa oscura para que se vea el icono
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.black.withOpacity(0.3), Colors.transparent],
//             ),
//           ),
//         ),
//         // Icono indicador (Triángulo, etc)
//         Positioned(
//           top: 4,
//           left: 4,
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: color, // Fondo del color de la opción
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Colors.white, size: 20),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:frontkahoot2526/features/games/common/timer.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

// class PlayerQuestionView extends StatelessWidget {
//   final CurrentQuestion question;
//   final Function(int) onAnswer;
//   final bool isLoading;
//   final int timeElapsed;

//   const PlayerQuestionView({
//     super.key,
//     required this.question,
//     required this.onAnswer,
//     this.isLoading = false,
//     this.timeElapsed = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final List<Color> optionColors = [
//       Colors.red, // Triángulo
//       Colors.blue, // Rombo
//       Colors.amber, // Círculo
//       Colors.green, // Cuadrado
//     ];

//     final List<IconData> optionIcons = [
//       Icons.change_history,
//       Icons.crop_square,
//       Icons.circle,
//       Icons.star,
//     ];

//     return Column(
//       children: [
//         //Pregunta actual y timer
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               //Pregunta
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//                 ),
//                 child: Text(
//                   "Pregunta ${question.questionIndex}",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.darkBlueText,
//                   ),
//                 ),
//               ),
//               //Timer
//               GameTimerWidget(totalSeconds: question.timeLimitSeconds),
//             ],
//           ),
//         ),

//         //Imagen y la pregunta
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               children: [
//                 // Imagen
//                 if (question.questionImageUrl != null)
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(color: Colors.black12, blurRadius: 8),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.network(
//                         question.questionImageUrl!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Container(
//                           color: Colors.grey[300],
//                           child: const Icon(
//                             Icons.image_not_supported,
//                             size: 50,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Texto de la Pregunta
//                 Text(
//                   question.questionText,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.darkBlueText,
//                     height: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 20),

//         //Sección de respuestas
//         if (isLoading)
//           const Padding(
//             padding: EdgeInsets.all(40),
//             child: CircularProgressIndicator(),
//           )
//         else
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: AspectRatio(
//               aspectRatio: 1.2,
//               child: GridView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 1.3,
//                 ),
//                 itemCount: question.options.length,
//                 itemBuilder: (context, index) {
//                   final option = question.options[index];
//                   final color = optionColors[index % optionColors.length];
//                   final icon = optionIcons[index % optionIcons.length];

//                   return _AnswerButton(
//                     text: "temporal",
//                     //text: option.answerText,
//                     color: color,
//                     icon: icon,
//                     onTap: () => onAnswer(index),
//                   );
//                 },
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// //Widget para las respuestas
// class _AnswerButton extends StatelessWidget {
//   final String text;
//   final Color color;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _AnswerButton({
//     required this.text,
//     required this.color,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: color,
//       borderRadius: BorderRadius.circular(12),
//       elevation: 4,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(5),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white, size: 26),
//               const SizedBox(width: 8),
//               Flexible(
//                 child: Text(
//                     text,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
