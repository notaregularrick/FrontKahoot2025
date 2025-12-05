import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontkahoot2526/core/domain/entities/answer.dart';
import 'package:frontkahoot2526/core/domain/entities/question.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/providers/create_quiz_service_provider.dart';
import 'package:frontkahoot2526/features/media/presentation/providers/media_service_provider.dart';

// Modelos de datos para gestionar el estado de preguntas y respuestas
class QuestionData {
  String id;
  String text;
  String type;
  int timeLimit;
  String? mediaId;
  List<AnswerData> answers;

  QuestionData({
    required this.id,
    required this.text,
    required this.type,
    required this.timeLimit,
    this.mediaId,
    required this.answers,
  });
}

class AnswerData {
  String id;
  String? text;
  bool isCorrect;
  String? mediaId;

  AnswerData({
    required this.id,
    this.text,
    required this.isCorrect,
    this.mediaId,
  });
}

class FromScratchScreen extends ConsumerStatefulWidget {
  const FromScratchScreen({super.key});

  @override
  ConsumerState<FromScratchScreen> createState() => _FromScratchScreenState();
}

class _FromScratchScreenState extends ConsumerState<FromScratchScreen> {
  String selectedQuizType = 'Quiz';
  List<QuestionData> questions = [];
  int currentQuestionIndex = 0;
  
  String quizTitle = '';
  String quizDescription = '';
  String quizCategory = 'Estudio';
  String quizVisibility = 'private';
  String? quizCoverImageId;

  @override
  void initState() {
    super.initState();
    // Inicializar con la primera pregunta
    _addNewQuestion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = GoRouterState.of(context);
    final uri = route.uri;
    final queryParams = uri.queryParameters;
    if (quizTitle.isEmpty && queryParams.isNotEmpty) {
      setState(() {
        quizTitle = Uri.decodeComponent(queryParams['title'] ?? '');
        quizDescription = Uri.decodeComponent(queryParams['description'] ?? '');
        quizCategory = Uri.decodeComponent(queryParams['category'] ?? 'Estudio');
        quizVisibility = queryParams['visibility'] ?? 'private';
      });
    }
  }

  void _addNewQuestion() {
    setState(() {
      questions.add(QuestionData(
        id: 'question_${DateTime.now().millisecondsSinceEpoch}_${questions.length}',
        text: '',
        type: _mapQuizTypeToQuestionType(selectedQuizType),
        timeLimit: 20,
        answers: [
          AnswerData(
            id: 'answer_${DateTime.now().millisecondsSinceEpoch}_0',
            text: null,
            isCorrect: false,
          ),
          AnswerData(
            id: 'answer_${DateTime.now().millisecondsSinceEpoch}_1',
            text: null,
            isCorrect: false,
          ),
          AnswerData(
            id: 'answer_${DateTime.now().millisecondsSinceEpoch}_2',
            text: null,
            isCorrect: false,
          ),
          AnswerData(
            id: 'answer_${DateTime.now().millisecondsSinceEpoch}_3',
            text: null,
            isCorrect: false,
          ),
        ],
      ));
      currentQuestionIndex = questions.length - 1;
    });
  }

  String _mapQuizTypeToQuestionType(String quizType) {
    switch (quizType) {
      case 'Verdadero/Falso':
        return 'true_false';
      case 'Encuesta':
        return 'survey';
      default:
        return 'quiz';
    }
  }

  QuestionData get currentQuestion => questions[currentQuestionIndex];

  Future<void> _createQuiz() async {
    // Validar que haya al menos una pregunta con texto
    final validQuestions = questions.where((q) => q.text.trim().isNotEmpty).toList();
    if (validQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos una pregunta')),
      );
      return;
    }

    // Validar que cada pregunta tenga al menos una respuesta
    for (var question in validQuestions) {
      final validAnswers = question.answers.where((a) => 
        (a.text != null && a.text!.trim().isNotEmpty) || 
        (a.mediaId != null && a.mediaId!.trim().isNotEmpty)
      ).toList();
      if (validAnswers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cada pregunta debe tener al menos una respuesta')),
        );
        return;
      }
      
      // Validar que al menos una respuesta esté marcada como correcta
      if (question.type == 'quiz' || question.type == 'true_false') {
        final hasCorrectAnswer = validAnswers.any((a) => a.isCorrect);
        if (!hasCorrectAnswer) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cada pregunta debe tener al menos una respuesta correcta')),
          );
          return;
        }
      }
    }

    // Construir entidades Question
    final questionEntities = validQuestions.map((q) {
      final validAnswers = q.answers
          .where((a) => 
            (a.text != null && a.text!.trim().isNotEmpty) || 
            (a.mediaId != null && a.mediaId!.trim().isNotEmpty)
          )
          .map((a) => Answer(
                id: a.id,
                text: a.text,
                isCorrect: a.isCorrect,
                mediaId: a.mediaId,
              ))
          .toList();

      return Question(
        id: q.id,
        text: q.text,
        type: q.type,
        timeLimit: q.timeLimit,
        points: 1000, 
        mediaId: q.mediaId,
        answers: validAnswers,
      );
    }).toList();

    // Construir entidad Quiz
    final quiz = Quiz(
      id: '', // Será generado por el repositorio
      title: quizTitle,
      description: quizDescription,
      coverImageId: quizCoverImageId,
      visibility: quizVisibility,
      status: 'draft',
      category: quizCategory,
      themeId: 'default-theme-id', 
      authorId: 'default-author-id', 
      authorName: 'Usuario', 
      questions: questionEntities,
      createdAt: DateTime.now(),
      playCount: 0,
    );

    try {
      final service = ref.read(createQuizServiceProvider);
      final createdQuiz = await service.createQuiz(quiz);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz "${createdQuiz.title}" creado exitosamente')),
        );
        context.go('/create-kahoot');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el quiz: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQ = currentQuestion;
    final answerColors = [
      const Color.fromARGB(255, 189, 4, 16),
      const Color.fromARGB(255, 9, 64, 203),
      const Color.fromARGB(255, 217, 132, 4),
      const Color.fromARGB(255, 1, 128, 12),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: PopupMenuButton<String>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  selectedQuizType,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 20),
              ],
            ),
          ),
          onSelected: (value) {
            setState(() {
              selectedQuizType = value;
              currentQ.type = _mapQuizTypeToQuestionType(value);
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Quiz', child: Text('Quiz')),
            const PopupMenuItem(value: 'Verdadero/Falso', child: Text('Verdadero/Falso')),
            const PopupMenuItem(value: 'Encuesta', child: Text('Encuesta')),
          ],
        ),
        actions: [
          if (questions.length > 1)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  questions.removeAt(currentQuestionIndex);
                  if (currentQuestionIndex >= questions.length) {
                    currentQuestionIndex = questions.length - 1;
                  }
                });
              },
            ),
          TextButton(
            onPressed: _createQuiz,
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón Añadir multimedia y tiempo
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _uploadQuizCoverImage(),
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
                    '${currentQ.timeLimit} s',
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
            // Mostrar imagen de portada si existe
            if (quizCoverImageId != null && quizCoverImageId!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ref.read(mediaServiceProvider).getMediaUrl(quizCoverImageId!),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    'Error al cargar imagen',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        setState(() {
                          quizCoverImageId = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
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
                child: currentQ.text.isEmpty
                    ? const Text(
                        'Pulsa para añadir una pregunta',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        currentQ.text,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Grid de respuestas 
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: List.generate(4, (index) {
                final answer = currentQ.answers[index];
                final hasText = answer.text != null && answer.text!.trim().isNotEmpty;
                final hasImage = answer.mediaId != null && answer.mediaId!.isNotEmpty;
                return _buildAnswerButton(
                  color: answerColors[index],
                  label: hasText ? answer.text! : (index < 2 ? 'Añadir respuesta' : 'Añadir respuesta (opcional)'),
                  isOptional: index >= 2,
                  index: index,
                  isCorrect: answer.isCorrect,
                  hasText: hasText,
                  hasImage: hasImage,
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flechas de navegación solo si hay múltiples preguntas
              if (questions.length > 1) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: currentQuestionIndex > 0
                      ? () {
                          setState(() {
                            currentQuestionIndex--;
                          });
                        }
                      : null,
                  color: currentQuestionIndex > 0 ? Colors.black87 : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? () {
                          setState(() {
                            currentQuestionIndex++;
                          });
                        }
                      : null,
                  color: currentQuestionIndex < questions.length - 1 ? Colors.black87 : Colors.grey,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Pregunta ${currentQuestionIndex + 1} de ${questions.length}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: _addNewQuestion,
                backgroundColor: Colors.blue[600],
                mini: false,
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton({
    required Color color,
    required String label,
    required bool isOptional,
    required int index,
    required bool isCorrect,
    required bool hasText,
    required bool hasImage,
  }) {
    final currentQ = currentQuestion;
    final answer = currentQ.answers[index];
    final mediaService = ref.read(mediaServiceProvider);
    
    return Stack(
      children: [
        Row(children: [
          Expanded(child: ElevatedButton(
          onPressed: () {
            _showAnswerDialog(context, index, color);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasImage
                ? Image.network(
                    mediaService.getMediaUrl(answer.mediaId!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: color,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: color,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white),
                              const SizedBox(height: 8),
                              Text(
                                'Error al cargar imagen',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasText)
                          Expanded(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ),)
        ],),
        // Slide de respuesta correcta
        if ((hasText || hasImage) && (currentQ.type == 'quiz' || currentQ.type == 'true_false'))
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // Si se marca como correcta, desmarcar todas las demás
                  if (!answer.isCorrect) {
                    for (var otherAnswer in currentQ.answers) {
                      if (otherAnswer != answer) {
                        otherAnswer.isCorrect = false;
                      }
                    }
                  }
                  answer.isCorrect = !answer.isCorrect;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.white : Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isCorrect
                    ? const Icon(Icons.check, color: Colors.black, size: 16)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  void _showQuestionDialog(BuildContext context) {
    final currentQ = currentQuestion;
    final TextEditingController controller = TextEditingController(text: currentQ.text);
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
                currentQ.text = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
  String? currentMediaId;
  void _showAnswerDialog(BuildContext context, int index, Color color) {
    final currentQ = currentQuestion;
    final answer = currentQ.answers[index];
    final TextEditingController controller = TextEditingController(text: answer.text ?? '');
    bool isCorrect = answer.isCorrect;
    currentMediaId = answer.mediaId;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Añadir respuesta ${index + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar imagen actual si existe
                if (currentMediaId != null && currentMediaId!.isNotEmpty) ...[
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ref.read(mediaServiceProvider).getMediaUrl(currentMediaId!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error_outline),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      setDialogState(() {
                        currentMediaId = null;
                        answer.mediaId = null;
                      });
                      // Actualizar estado del widget principal
                      setState(() {
                        answer.mediaId = null;
                      });
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar imagen'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: controller,
                  enabled: currentMediaId == null,
                  decoration: InputDecoration(
                    hintText: currentMediaId != null 
                        ? 'Elimina la imagen para escribir texto' 
                        : 'Escribe la respuesta aquí',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Botón para subir imagen
                if (currentMediaId == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _uploadAnswerImage(index, setDialogState),
                      icon: const Icon(Icons.image),
                      label: const Text('Subir imagen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                // Checkbox para marcar respuesta correcta
                if (currentQ.type == 'quiz' || currentQ.type == 'true_false') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isCorrect,
                        onChanged: (value) {
                          setDialogState(() {
                            isCorrect = value ?? false;
                          });
                        },
                      ),
                      const Expanded(child: Text('Marcar como respuesta correcta')),
                    ],
                  ),
                ],
              ],
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
                  // Si hay imagen, limpiar texto
                  print(answer.mediaId);
                  if (currentMediaId != null && currentMediaId!.isNotEmpty) {
                    answer.text = null;
                    answer.mediaId = currentMediaId;
                  } else {
                    // Si hay texto, limpiar imagen
                    answer.text = controller.text.trim().isEmpty ? null : controller.text.trim();
                    answer.mediaId = null;
                  }
                  print(answer.text);
                  print(answer.mediaId);
                  print(currentMediaId);
                  // Si se marca como correcta, desmarcar todas las demás
                  if (isCorrect && (currentQ.type == 'quiz' || currentQ.type == 'true_false')) {
                    for (var otherAnswer in currentQ.answers) {
                      if (otherAnswer != answer) {
                        otherAnswer.isCorrect = false;
                      }
                    }
                  }
                  
                  answer.isCorrect = isCorrect;
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadQuizCoverImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      // Mostrar indicador de carga
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final mediaService = ref.read(mediaServiceProvider);
        final file = File(image.path);
        final media = await mediaService.uploadMedia(file);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar indicador de carga
          setState(() {
            quizCoverImageId = media.id;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen de portada subida exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar indicador de carga
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imagen: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _uploadAnswerImage(int index, StateSetter setDialogState) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      // Mostrar indicador de carga
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final mediaService = ref.read(mediaServiceProvider);
        final file = File(image.path);
        final media = await mediaService.uploadMedia(file);

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar indicador de carga
          final answer = currentQuestion.answers[index];
          // Actualizar estado del diálogo
          setDialogState(() {
            currentMediaId = media.id;
          });
          // Actualizar estado del widget principal para forzar reconstrucción
          setState(() {
            currentMediaId = media.id;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar indicador de carga
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imagen: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: ${e.toString()}')),
        );
      }
    }
  }

  void _showTimePicker(BuildContext context) {
    final currentQ = currentQuestion;
    final List<int> timeOptions = [5, 10, 20, 30, 45, 60, 90, 120, 180, 240];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiempo límite'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: timeOptions.length,
            itemBuilder: (context, index) {
              final time = timeOptions[index];
              final isSelected = currentQ.timeLimit == time;
              
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentQ.timeLimit = time;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.purple[600] : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  elevation: isSelected ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '$time s',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
