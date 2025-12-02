import 'package:flutter/material.dart';

class FromScratchScreen extends StatefulWidget {
  const FromScratchScreen({super.key});

  @override
  State<FromScratchScreen> createState() => _FromScratchScreenState();
}

class _FromScratchScreenState extends State<FromScratchScreen> {
  String selectedQuizType = 'Quiz';
  String questionText = '';
  int timeLimit = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedQuizType,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Colors.black87),
              ],
            ),
          ),
          onSelected: (value) {
            setState(() {
              selectedQuizType = value;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Quiz', child: Text('Quiz')),
            const PopupMenuItem(value: 'Verdadero/Falso', child: Text('Verdadero/Falso')),
            const PopupMenuItem(value: 'Encuesta', child: Text('Encuesta')),
          ],
        ),
        centerTitle: true,
        title: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onPressed: () {
            // Menú de opciones
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Acción de "Listo"
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Listo',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón Añadir multimedia y tiempo
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Añadir multimedia
                    },
                    icon: const Icon(Icons.add_photo_alternate, color: Colors.black87),
                    label: const Text(
                      'Añadir multimedia',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _showTimePicker(context);
                  },
                  icon: const Icon(Icons.access_time, color: Colors.white),
                  label: Text(
                    '$timeLimit s',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Campo de pregunta
            GestureDetector(
              onTap: () {
                _showQuestionDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(minHeight: 120),
                child: questionText.isEmpty
                    ? const Text(
                        'Pulsa para añadir una pregunta',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        questionText,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Grid de respuestas 2x2
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildAnswerButton(
                  color: Colors.red[400]!,
                  label: 'Añadir respuesta',
                  isOptional: false,
                  index: 0,
                ),
                _buildAnswerButton(
                  color: Colors.blue[400]!,
                  label: 'Añadir respuesta',
                  isOptional: false,
                  index: 1,
                ),
                _buildAnswerButton(
                  color: Colors.orange[400]!,
                  label: 'Añadir respuesta (opcional)',
                  isOptional: true,
                  index: 2,
                ),
                _buildAnswerButton(
                  color: Colors.green[400]!,
                  label: 'Añadir respuesta (opcional)',
                  isOptional: true,
                  index: 3,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Añadir nueva pregunta
        },
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildAnswerButton({
    required Color color,
    required String label,
    required bool isOptional,
    required int index,
  }) {
    return ElevatedButton(
      onPressed: () {
        _showAnswerDialog(context, index, color);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showQuestionDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: questionText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir pregunta'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe tu pregunta aquí',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                questionText = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAnswerDialog(BuildContext context, int index, Color color) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir respuesta ${index + 1}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Escribe la respuesta aquí',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Guardar respuesta
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiempo límite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: timeLimit.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$timeLimit segundos',
              onChanged: (value) {
                setState(() {
                  timeLimit = value.toInt();
                });
              },
            ),
            Text('$timeLimit segundos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Listo'),
          ),
        ],
      ),
    );
  }
}

