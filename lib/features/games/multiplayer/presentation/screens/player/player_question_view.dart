import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/common/timer.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class PlayerQuestionView extends StatefulWidget {
  final CurrentQuestion question;
  // ✅ CAMBIO 1: Ahora devolvemos una lista de Strings (IDs)
  final Function(List<String>) onAnswer; 
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
  // Mantenemos índices internamente para controlar la UI (bordes, selección)
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
    _localTimer = Timer(Duration(seconds: widget.question.timeLimitSeconds), () {
      if (mounted) setState(() => _isTimeUp = true);
    });
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
      // ✅ CAMBIO 2: Selección Única (Single / TrueFalse)
      // Buscamos el ID real de la respuesta usando el índice
      final String answerId = widget.question.options[index].answerIndex;
      widget.onAnswer([answerId]);
    }
  }

  void _submitMultipleAnswers() {
    if (_isTimeUp || widget.isLoading) return;
    
    if (_selectedIndexes.isNotEmpty) {
      // ✅ CAMBIO 3: Selección Múltiple
      // Convertimos los índices visuales (0, 1...) a los IDs reales del backend
      final List<String> selectedIds = _selectedIndexes.map((index) {
        return widget.question.options[index].answerIndex;
      }).toList();

      widget.onAnswer(selectedIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiple = widget.question.type == QuestionType.multipleChoice;
    final bottomContentPadding = isMultiple ? 100.0 : 30.0;

    return Stack(
      children: [
        Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Text(
                      "Pregunta ${widget.question.questionIndex + 1}",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlueText),
                    ),
                  ),
                  GameTimerWidget(totalSeconds: widget.question.timeLimitSeconds),
                ],
              ),
            ),

            // --- CUERPO UNIFICADO ---
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomContentPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // IMAGEN
                      if (widget.question.questionImageUrl.isNotEmpty)
                        Container(
                          height: 180,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
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

                      // TEXTO
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

                      // CHIP MULTIPLE
                      if (isMultiple)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Chip(
                            label: const Text("Selección Múltiple"),
                            backgroundColor: Colors.orange.withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                            side: BorderSide.none,
                          ),
                        ),

                      const SizedBox(height: 32),

                      // RESPUESTAS
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

        // --- BOTÓN FLOTANTE (Solo Multiple) ---
        if (isMultiple && !widget.isLoading && !_isTimeUp)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _selectedIndexes.isNotEmpty 
                  ? _submitMultipleAnswers // Llama a la función que mapea IDs
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("ENVIAR RESPUESTA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

        // --- OVERLAY TIEMPO AGOTADO ---
        if (_isTimeUp)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_off_outlined, color: Colors.white, size: 80),
                      const SizedBox(height: 24),
                      const Text(
                        "¡Se acabó el tiempo!",
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
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

  // --- MÉTODOS DE LAYOUT ---

  Widget _buildAnswerLayout() {
    if (widget.question.type == QuestionType.trueFalse) {
      return _buildTrueFalseLayout();
    } else {
      return _buildStandardGrid();
    }
  }

  Widget _buildTrueFalseLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120,
          width: double.infinity,
          child: _AnswerCard(
            option: widget.question.options.isNotEmpty ? widget.question.options[0] : null,
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
            option: widget.question.options.length > 1 ? widget.question.options[1] : null,
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
    final List<Color> colors = [Colors.red, Colors.blue, const Color(0xFFD69E00), Colors.green];
    final List<IconData> icons = [Icons.change_history, Icons.crop_square_outlined, Icons.circle, Icons.square];

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

// --- CLASE _AnswerCard (IGUAL QUE ANTES) ---
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
    final hasImage = option?.answerImageUrl != null && option!.answerImageUrl!.isNotEmpty;
    final textToShow = labelOverride ?? option?.answerText ?? "";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.darkBlueText, width: 5) : null,
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
                  child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 40)),
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
                shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
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
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error, color: Colors.white)),
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
          top: 4, left: 4,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ],
    );
  }
}