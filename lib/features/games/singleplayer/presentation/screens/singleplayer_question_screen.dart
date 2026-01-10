import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/common/timer.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class SingleplayerQuestionScreen extends StatefulWidget {
  final Map<String, dynamic> slide;
  final int currentScore;
  final void Function(List<int> answerIndexes, int timeElapsedMs) onAnswer;

  const SingleplayerQuestionScreen({super.key, required this.slide, required this.currentScore, required this.onAnswer});

  @override
  State<SingleplayerQuestionScreen> createState() => _SingleplayerQuestionScreenState();
}

class _SingleplayerQuestionScreenState extends State<SingleplayerQuestionScreen> {
  late DateTime _startTime;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void didUpdateWidget(covariant SingleplayerQuestionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slide['slideId'] != widget.slide['slideId']) {
      _startTime = DateTime.now();
      _selected.clear();
    }
  }

  void _handleSingleAnswer(int index) {
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    widget.onAnswer([index], elapsed);
  }

  void _toggleMulti(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  void _submitMulti() {
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    widget.onAnswer(_selected.toList()..sort(), elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;
    final options = (slide['options'] as List).cast<Map<String, dynamic>>();
    final questionType = (slide['questionType'] as String?)?.toLowerCase() ?? '';
    final multiSelect = questionType.contains('multi');

    // Use the real number of options; do not pad
    final padded = List<Map<String, dynamic>>.from(options);

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

        // Sección de respuestas: grid dinámico según cantidad, contenido flexible para evitar overflow
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool singleColumn = padded.length <= 2;
                final double aspect = singleColumn ? 3.0 : 1.0;

                return GridView.builder(
                  primary: false,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: singleColumn ? 1 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: aspect,
                  ),
                  itemCount: padded.length,
                  itemBuilder: (context, index) {
                    final opt = padded[index];
                    final color = optionColors[index % optionColors.length];
                    final icon = optionIcons[index % optionIcons.length];

                    return _AnswerButton(
                      text: opt['text'] as String? ?? '',
                      imageUrl: opt['mediaUrl'] as String?,
                      color: color,
                      icon: icon,
                      selected: _selected.contains(opt['index'] as int),
                      onTap: () => multiSelect ? _toggleMulti(opt['index'] as int) : _handleSingleAnswer(opt['index'] as int),
                    );
                  },
                );
              },
            ),
          ),
        ),

        if (multiSelect)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () => _submitMulti(),
              child: const Text('Confirmar selección'),
            ),
          ),
      ],
    );
  }
}

// Widget para las respuestas (estilo multiplayer)
class _AnswerButton extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  const _AnswerButton({required this.text, this.imageUrl, required this.color, required this.icon, required this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withOpacity(0.8) : color,
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
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              if (imageUrl != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.white70, size: 36),
                    ),
                  ),
                )
              else
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
