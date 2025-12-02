import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/core/domain/entities/answer.dart';
import 'package:frontkahoot2526/core/domain/entities/question.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/providers/create_quiz_service_provider.dart';

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
      final validAnswers = question.answers.where((a) => a.text != null && a.text!.trim().isNotEmpty).toList();
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
          .where((a) => a.text != null && a.text!.trim().isNotEmpty)
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
      coverImageId: null,
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
      Colors.red[400]!,
      Colors.blue[400]!,
      Colors.orange[400]!,
      Colors.green[400]!,
    ];

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
              currentQ.type = _mapQuizTypeToQuestionType(value);
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Quiz', child: Text('Quiz')),
            const PopupMenuItem(value: 'Verdadero/Falso', child: Text('Verdadero/Falso')),
            const PopupMenuItem(value: 'Encuesta', child: Text('Encuesta')),
          ],
        ),
        centerTitle: true,
        title: Text(
          'Pregunta ${currentQuestionIndex + 1} de ${questions.length}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navegación de preguntas si hay múltiples preguntas
            if (questions.length > 1)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: currentQuestionIndex > 0
                          ? () {
                              setState(() {
                                currentQuestionIndex--;
                              });
                            }
                          : null,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Pregunta ${currentQuestionIndex + 1} de ${questions.length}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: currentQuestionIndex < questions.length - 1
                          ? () {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Botón Añadir multimedia y tiempo
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Añadir multimedia (funcionalidad pendiente)
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
            // Grid de respuestas 2x2
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
                return _buildAnswerButton(
                  color: answerColors[index],
                  label: hasText ? answer.text! : (index < 2 ? 'Añadir respuesta' : 'Añadir respuesta (opcional)'),
                  isOptional: index >= 2,
                  index: index,
                  isCorrect: answer.isCorrect,
                  hasText: hasText,
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewQuestion,
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
    required bool isCorrect,
    required bool hasText,
  }) {
    final currentQ = currentQuestion;
    final answer = currentQ.answers[index];
    
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
            padding: const EdgeInsets.all(16),
          ),
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
        ),)
        ],),
        // Slide de respuesta correcta
        if (hasText && (currentQ.type == 'quiz' || currentQ.type == 'true_false'))
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

  void _showAnswerDialog(BuildContext context, int index, Color color) {
    final currentQ = currentQuestion;
    final answer = currentQ.answers[index];
    final TextEditingController controller = TextEditingController(text: answer.text ?? '');
    bool isCorrect = answer.isCorrect;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Añadir respuesta ${index + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Escribe la respuesta aquí',
                  border: OutlineInputBorder(),
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
                    Expanded(child: const Text('Marcar como respuesta correcta')) ,
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  answer.text = controller.text.trim().isEmpty ? null : controller.text.trim();
                  
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
