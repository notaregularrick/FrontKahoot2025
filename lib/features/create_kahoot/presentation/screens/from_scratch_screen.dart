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
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_notifier.dart';
import 'package:frontkahoot2526/core/providers/backend_provider.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/providers/quiz_preload_provider.dart';
import 'package:frontkahoot2526/features/categories/presentation/providers/categories_provider.dart';

// Modelos de datos para gestionar el estado de preguntas y respuestas
class QuestionData {
  String id;
  String text;
  String type;
  int timeLimit;
  int points;
  String? mediaId;
  List<AnswerData> answers;

  QuestionData({
    required this.id,
    required this.text,
    required this.type,
    required this.timeLimit,
    required this.points,
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
  String? quizCoverImageId; // ID para enviar al backend
  String? quizCoverImageUrl; // URL para mostrar preview
  Map<String, String?> questionImageUrls =
      {}; // Map<questionId, imageUrl> para preview de imágenes de preguntas
  Map<String, String?> answerImageUrls =
      {}; // Map<answerId, imageUrl> para preview de imágenes de respuestas
  String? _defaultThemeId;
  bool _isEditMode = false;
  String? _editingKahootId;
  bool _isLoadingExisting = false;
  String quizStatus = 'draft';

  @override
  void initState() {
    super.initState();
    // Inicializar con la primera pregunta
    _addNewQuestion();
    // Cargar themeId del backend
    _loadDefaultTheme();
  }

  Future<void> _loadExistingQuiz(String kahootId) async {
    setState(() {
      _isLoadingExisting = true;
    });
    try {
      final service = ref.read(createQuizServiceProvider);
      final quiz = await service.getQuiz(kahootId);

      setState(() {
        quizTitle = quiz.title;
        quizDescription = quiz.description;
        quizCategory = quiz.category.isNotEmpty ? quiz.category : 'Estudio';
        quizVisibility = quiz.visibility.isNotEmpty
            ? quiz.visibility
            : 'private';
        quizStatus = quiz.status.isNotEmpty ? quiz.status : 'draft';
        quizCoverImageId = quiz.coverImageId;
        quizCoverImageUrl = _resolveMediaUrl(quiz.coverImageId);
        questionImageUrls.clear(); // Limpiar URLs anteriores
        questions = quiz.questions.map((q) {
          // Resolver URL de imagen de pregunta si existe
          if (q.mediaId != null && q.mediaId!.isNotEmpty) {
            questionImageUrls[q.id] = _resolveMediaUrl(q.mediaId);
          }
          return QuestionData(
            id: q.id,
            text: _truncate(q.text, 120),
            type: q.type,
            timeLimit: q.timeLimit,
            points: q.points,
            mediaId: q.mediaId,
            answers: q.answers
                .map(
                  (a) => AnswerData(
                    id: a.id,
                    text: a.text,
                    isCorrect: a.isCorrect,
                    mediaId: a.mediaId,
                  ),
                )
                .toList(),
          );
        }).toList();
        if (questions.isEmpty) {
          _addNewQuestion();
        }
        currentQuestionIndex = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar el kahoot: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingExisting = false;
        });
      }
    }
  }

  String _truncate(String text, int max) {
    if (text.length <= max) return text;
    return text.substring(0, max);
  }

  String? _resolveMediaUrl(String? idOrUrl) {
    if (idOrUrl == null || idOrUrl.isEmpty) return null;
    if (idOrUrl.startsWith('http')) return idOrUrl;

    final base = ref.read(backendProvider).url;
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return '$normalizedBase/media/$idOrUrl';
  }

  Future<void> _loadDefaultTheme() async {
    try {
      final mediaService = ref.read(mediaServiceProvider);
      final themes = await mediaService.getThemes();
      if (themes.isNotEmpty && mounted) {
        setState(() {
          _defaultThemeId = themes.first.assetId;
        });
      }
    } catch (e) {
      // Si falla, continuamos sin theme - el usuario verá un error al crear
    }
  }

  Future<void> _loadCoverImageUrl(String mediaId) async {
    try {
      // Si el mediaId ya es una URL completa, la usamos directamente
      if (mediaId.startsWith('http://') || mediaId.startsWith('https://')) {
        setState(() {
          quizCoverImageUrl = mediaId;
        });
      } else {
        // Si no es una URL completa, intentamos construirla
        // No establecemos quizCoverImageUrl para que el usuario pueda subir una nueva imagen si lo desea
      }
    } catch (e) {
      // Error al cargar URL de imagen de portada
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = GoRouterState.of(context);
    final uri = route.uri;
    final queryParams = uri.queryParameters;

    // Modo edición: si viene kid en query y aún no lo hemos cargado
    final kid = queryParams['kid'];
    if (!_isEditMode && kid != null && kid.isNotEmpty) {
      _isEditMode = true;
      _editingKahootId = kid;
      _loadExistingQuiz(kid);
      return; // No procesar más si estamos en modo edición
    }

    // Verificar si hay datos precargados en el provider
    // Usar postFrameCallback para evitar modificar provider durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final preloadData = ref
          .read(quizPreloadProvider.notifier)
          .consumePreloadData();
      if (preloadData != null) {
        _loadPreloadedData(preloadData);
      }
    });
  }

  /// Carga datos precargados desde el provider
  void _loadPreloadedData(QuizPreloadData data) {
    setState(() {
      quizTitle = data.title;
      quizDescription = data.description;
      quizCategory = data.category;
      quizVisibility = data.visibility;

      // Cargar coverImageId y coverImageUrl si existen
      if (data.coverImageId != null && data.coverImageId!.isNotEmpty) {
        quizCoverImageId = data.coverImageId;
        if (data.coverImageUrl != null && data.coverImageUrl!.isNotEmpty) {
          quizCoverImageUrl = data.coverImageUrl;
        } else {
          // Intentar construir URL desde el ID
          _loadCoverImageUrl(data.coverImageId!);
        }
      }

      // Cargar preguntas
      questions.clear();
      for (int i = 0; i < data.questions.length; i++) {
        final preloadedQ = data.questions[i];
        final answers = <AnswerData>[];

        // Convertir respuestas precargadas a AnswerData
        for (int j = 0; j < preloadedQ.answers.length; j++) {
          final preloadedA = preloadedQ.answers[j];
          answers.add(
            AnswerData(
              id: 'answer_${i}_$j',
              text: preloadedA.text,
              isCorrect: preloadedA.isCorrect,
              mediaId: null,
            ),
          );
        }

        // Validar y completar respuestas según el tipo de pregunta
        final requiredAnswers = preloadedQ.type == 'true_false' ? 2 : 4;
        final minRequiredAnswers = preloadedQ.type == 'true_false' ? 2 : 2;

        // Completar respuestas faltantes
        while (answers.length < requiredAnswers) {
          if (preloadedQ.type == 'true_false') {
            answers.add(
              AnswerData(
                id: 'answer_${i}_${answers.length}',
                text: answers.length == 0 ? 'Verdadero' : 'Falso',
                isCorrect: false,
                mediaId: null,
              ),
            );
          } else {
            answers.add(
              AnswerData(
                id: 'answer_${i}_${answers.length}',
                text: null,
                isCorrect: false,
                mediaId: null,
              ),
            );
          }
        }

        // Solo agregar la pregunta si tiene al menos el mínimo requerido
        if (answers.length >= minRequiredAnswers) {
          questions.add(
            QuestionData(
              id: 'question_$i',
              text: preloadedQ.text,
              type: preloadedQ.type,
              timeLimit: preloadedQ.timeLimit,
              points: preloadedQ.points,
              mediaId: null,
              answers: answers,
            ),
          );
        }
      }

      if (questions.isNotEmpty) {
        currentQuestionIndex = 0;
      } else {
        _addNewQuestion();
      }
    });
  }

  void _addNewQuestion() {
    setState(() {
      final questionType = _mapQuizTypeToQuestionType(selectedQuizType);
      final isTrueFalse = questionType == 'true_false';

      questions.add(
        QuestionData(
          id: 'question_${DateTime.now().millisecondsSinceEpoch}_${questions.length}',
          text: '',
          type: questionType,
          timeLimit: 20,
          points: 1000,
          answers: [
            AnswerData(
              id: 'answer_${DateTime.now().millisecondsSinceEpoch}_0',
              text: isTrueFalse ? 'Verdadero' : null,
              isCorrect: false,
            ),
            AnswerData(
              id: 'answer_${DateTime.now().millisecondsSinceEpoch}_1',
              text: isTrueFalse ? 'Falso' : null,
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
        ),
      );
      currentQuestionIndex = questions.length - 1;
    });
  }

  String _mapQuizTypeToQuestionType(String quizType) {
    switch (quizType) {
      case 'Verdadero/Falso':
        return 'true_false';
      case 'Selección Múltiple':
        return 'multiple';
      default:
        return 'quiz';
    }
  }

  QuestionData get currentQuestion => questions[currentQuestionIndex];

  Future<void> _createQuiz() async {
    // Validar que se haya cargado el themeId
    if (_defaultThemeId == null || _defaultThemeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo cargar el tema. Intenta de nuevo.'),
        ),
      );
      // Intentar cargar el theme de nuevo
      await _loadDefaultTheme();
      return;
    }

    // Validar que haya al menos una pregunta con texto
    final validQuestions = questions
        .where((q) => q.text.trim().isNotEmpty)
        .toList();
    if (validQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos una pregunta')),
      );
      return;
    }

    // Validar que cada pregunta tenga al menos una respuesta
    for (var question in validQuestions) {
      final validAnswers = question.answers
          .where(
            (a) =>
                (a.text != null && a.text!.trim().isNotEmpty) ||
                (a.mediaId != null && a.mediaId!.trim().isNotEmpty),
          )
          .toList();
      if (validAnswers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cada pregunta debe tener al menos una respuesta'),
          ),
        );
        return;
      }

      // Validar que al menos una respuesta esté marcada como correcta
      if (question.type == 'quiz' || question.type == 'true_false') {
        final hasCorrectAnswer = validAnswers.any((a) => a.isCorrect);
        if (!hasCorrectAnswer) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cada pregunta debe tener al menos una respuesta correcta',
              ),
            ),
          );
          return;
        }
      }

      // Validar que para selección múltiple haya al menos 2 respuestas correctas
      if (question.type == 'multiple') {
        final correctAnswersCount = validAnswers
            .where((a) => a.isCorrect)
            .length;
        if (correctAnswersCount < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Las preguntas de selección múltiple deben tener al menos 2 respuestas correctas',
              ),
            ),
          );
          return;
        }
      }
    }

    // Construir entidades Question
    final questionEntities = validQuestions.map((q) {
      final validAnswers = q.answers
          .where(
            (a) =>
                (a.text != null && a.text!.trim().isNotEmpty) ||
                (a.mediaId != null && a.mediaId!.trim().isNotEmpty),
          )
          .map(
            (a) => Answer(
              id: a.id,
              text: a.text,
              isCorrect: a.isCorrect,
              mediaId: a.mediaId,
            ),
          )
          .toList();

      return Question(
        id: q.id,
        text: _truncate(q.text, 120),
        type: q.type,
        timeLimit: q.timeLimit,
        points: q.points,
        mediaId: q.mediaId,
        answers: validAnswers,
      );
    }).toList();

    print('Title: $quizTitle');
    print('Description: $quizDescription');
    print('CoverImageId: $quizCoverImageId');
    print('Visibility: $quizVisibility');
    print('Category: $quizCategory');
    print('ThemeId: $_defaultThemeId');
    print('Status: draft');
    print('Questions: $questionEntities');

    // Construir entidad Quiz
    final quiz = Quiz(
      id: '', // Será generado por el repositorio
      title: quizTitle,
      description: quizDescription,
      coverImageId: quizCoverImageId,
      visibility: quizVisibility,
      status: 'draft',
      category: quizCategory,
      themeId: _defaultThemeId ?? '',
      authorId: '', // Será asignado por el backend
      authorName: '', // Será asignado por el backend
      questions: questionEntities,
      createdAt: DateTime.now(),
      playCount: 0,
    );

    try {
      final service = ref.read(createQuizServiceProvider);
      final createdQuiz = await service.createQuiz(quiz);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz "${createdQuiz.title}" creado exitosamente'),
          ),
        );
        context.go('/create-kahoot');
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el quiz: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingExisting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        leadingWidth: 200,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: PopupMenuButton<String>(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      selectedQuizType,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black87,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          onSelected: (value) {
            setState(() {
              selectedQuizType = value;
              final newType = _mapQuizTypeToQuestionType(value);
              currentQ.type = newType;

              // Si se cambia a modo Verdadero/Falso, establecer textos y limpiar imágenes
              if (newType == 'true_false') {
                for (int i = 0; i < currentQ.answers.length; i++) {
                  currentQ.answers[i].mediaId = null;
                  if (i < 2) {
                    currentQ.answers[i].text = i == 0 ? 'Verdadero' : 'Falso';
                  }
                }
              }
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Quiz', child: Text('Quiz')),
            const PopupMenuItem(
              value: 'Selección Múltiple',
              child: Text('Selección Múltiple'),
            ),
            const PopupMenuItem(
              value: 'Verdadero/Falso',
              child: Text('Verdadero/Falso'),
            ),
          ],
        ),
        actions: [
          if (questions.length > 1)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  final questionToRemove = questions[currentQuestionIndex];
                  // Limpiar URL de imagen si existe
                  questionImageUrls.remove(questionToRemove.id);
                  questions.removeAt(currentQuestionIndex);
                  if (currentQuestionIndex >= questions.length) {
                    currentQuestionIndex = questions.length - 1;
                  }
                });
              },
            ),
          TextButton(
            onPressed: _isEditMode ? _saveEditedQuiz : _createQuiz,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'duplicate') {
                _duplicateQuestion();
              } else if (value == 'points') {
                _showPointsPicker(context);
              } else if (value == 'metadata') {
                _showMetadataDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'metadata',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Editar información del quiz'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.content_copy, size: 20),
                    SizedBox(width: 8),
                    Text('Duplicar pregunta'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'points',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text('Cambiar puntos'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fila de multimedia y estado (sin scroll horizontal)
            Row(
              children: [
                if (_isEditMode) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag, color: Colors.black87, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          quizStatus == 'published' ? 'Publicado' : 'Borrador',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: quizStatus == 'published',
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              quizStatus = value ? 'published' : 'draft';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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
            const SizedBox(height: 12),
            // Imagen de pregunta
            if (currentQ.mediaId != null &&
                currentQ.mediaId!.isNotEmpty &&
                questionImageUrls[currentQ.id] != null) ...[
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
                        questionImageUrls[currentQ.id]!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                          currentQ.mediaId = null;
                          questionImageUrls.remove(currentQ.id);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _uploadQuestionImage,
                  icon: const Icon(
                    Icons.add_photo_alternate,
                    color: Colors.black87,
                  ),
                  label: const Text(
                    'Añadir imagen a la pregunta',
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
              const SizedBox(height: 12),
            ],
            // Tiempo debajo de la pregunta
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 110,
                child: ElevatedButton.icon(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Grid de respuestas
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: List.generate(currentQ.type == 'true_false' ? 2 : 4, (
                index,
              ) {
                // Proteger acceso a respuestas
                final answer = index < currentQ.answers.length
                    ? currentQ.answers[index]
                    : AnswerData(
                        id: 'temp_${currentQ.id}_$index',
                        text: currentQ.type == 'true_false'
                            ? (index == 0 ? 'Verdadero' : 'Falso')
                            : null,
                        isCorrect: false,
                        mediaId: null,
                      );
                final hasText =
                    answer.text != null && answer.text!.trim().isNotEmpty;
                final hasImage =
                    answer.mediaId != null && answer.mediaId!.isNotEmpty;
                String label;
                if (hasText) {
                  label = answer.text!;
                } else if (currentQ.type == 'true_false') {
                  label = index == 0 ? 'Verdadero' : 'Falso';
                } else {
                  label = index < 2
                      ? 'Añadir respuesta'
                      : 'Añadir respuesta (opcional)';
                }
                return _buildAnswerButton(
                  color: answerColors[index],
                  label: label,
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
                  color: currentQuestionIndex > 0
                      ? Colors.black87
                      : Colors.grey,
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
                  color: currentQuestionIndex < questions.length - 1
                      ? Colors.black87
                      : Colors.grey,
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

  Future<void> _saveEditedQuiz() async {
    if (_editingKahootId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de kahoot no válido')),
      );
      return;
    }

    final validQuestions = questions
        .where((q) => q.text.trim().isNotEmpty)
        .toList();
    if (validQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos una pregunta')),
      );
      return;
    }

    for (var question in validQuestions) {
      final validAnswers = question.answers
          .where(
            (a) =>
                (a.text != null && a.text!.trim().isNotEmpty) ||
                (a.mediaId != null && a.mediaId!.trim().isNotEmpty),
          )
          .toList();
      if (validAnswers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cada pregunta debe tener al menos una respuesta'),
          ),
        );
        return;
      }
      if (question.type == 'quiz' || question.type == 'true_false') {
        final hasCorrectAnswer = validAnswers.any((a) => a.isCorrect);
        if (!hasCorrectAnswer) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cada pregunta debe tener al menos una respuesta correcta',
              ),
            ),
          );
          return;
        }
      }
      if (question.type == 'multiple') {
        final correctAnswersCount = validAnswers
            .where((a) => a.isCorrect)
            .length;
        if (correctAnswersCount < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Las preguntas de selección múltiple deben tener al menos 2 respuestas correctas',
              ),
            ),
          );
          return;
        }
      }
    }

    final questionEntities = validQuestions.map((q) {
      final validAnswers = q.answers
          .where(
            (a) =>
                (a.text != null && a.text!.trim().isNotEmpty) ||
                (a.mediaId != null && a.mediaId!.trim().isNotEmpty),
          )
          .map(
            (a) => Answer(
              id: a.id,
              text: a.text,
              isCorrect: a.isCorrect,
              mediaId: a.mediaId,
            ),
          )
          .toList();

      return Question(
        id: q.id,
        text: _truncate(q.text, 120),
        type: q.type,
        timeLimit: q.timeLimit,
        points: q.points,
        mediaId: q.mediaId,
        answers: validAnswers,
      );
    }).toList();

    final quiz = Quiz(
      id: _editingKahootId ?? '',
      title: quizTitle,
      description: quizDescription,
      coverImageId: quizCoverImageId,
      visibility: quizVisibility,
      status: quizStatus,
      category: quizCategory,
      themeId: _defaultThemeId ?? '',
      authorId: '',
      authorName: '',
      questions: questionEntities,
      createdAt: DateTime.now(),
      playCount: 0,
    );

    try {
      final service = ref.read(createQuizServiceProvider);
      final updatedQuiz = await service.updateQuiz(_editingKahootId!, quiz);
      if (mounted) {
        try {
          ref.invalidate(asyncLibraryProvider);
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz "${updatedQuiz.title}" actualizado')),
        );
        context.go('/library');
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el quiz: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
      }
    }
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
    // Proteger acceso a respuestas
    if (index >= currentQ.answers.length) {
      // Si no existe la respuesta, crear una temporal
      final tempAnswer = AnswerData(
        id: 'temp_${currentQ.id}_$index',
        text: currentQ.type == 'true_false'
            ? (index == 0 ? 'Verdadero' : 'Falso')
            : null,
        isCorrect: false,
        mediaId: null,
      );
      // Agregar la respuesta temporal a la pregunta
      currentQ.answers.add(tempAnswer);
    }
    final answer = currentQ.answers[index];

    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
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
                  child: hasImage && currentQ.type != 'true_false'
                      ? Image.network(
                          answerImageUrls[answer.id] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: color,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
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
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error al cargar imagen',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
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
              ),
            ),
          ],
        ),
        // Slide de respuesta correcta
        if ((hasText || hasImage) &&
            (currentQ.type == 'quiz' ||
                currentQ.type == 'multiple' ||
                currentQ.type == 'true_false'))
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // Si se marca como correcta, desmarcar todas las demás (solo para quiz y true_false, no para multiple)
                  if (!answer.isCorrect && currentQ.type != 'multiple') {
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
    final TextEditingController controller = TextEditingController(
      text: currentQ.text,
    );
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

  String? currentMediaId; // ID para guardar en la respuesta
  String? currentMediaUrl; // URL para mostrar preview
  void _showAnswerDialog(BuildContext context, int index, Color color) {
    final currentQ = currentQuestion;
    // Proteger acceso a respuestas
    if (index >= currentQ.answers.length) {
      // Si no existe la respuesta, crear una temporal y agregarla
      final tempAnswer = AnswerData(
        id: 'temp_${currentQ.id}_$index',
        text: currentQ.type == 'true_false'
            ? (index == 0 ? 'Verdadero' : 'Falso')
            : null,
        isCorrect: false,
        mediaId: null,
      );
      currentQ.answers.add(tempAnswer);
    }
    final answer = currentQ.answers[index];
    // En modo Verdadero/Falso, establecer el texto automáticamente
    if (currentQ.type == 'true_false' && index < 2) {
      answer.text = index == 0 ? 'Verdadero' : 'Falso';
    }
    final TextEditingController controller = TextEditingController(
      text: answer.text ?? '',
    );
    bool isCorrect = answer.isCorrect;
    currentMediaId = answer.mediaId;
    currentMediaUrl = answerImageUrls[answer.id] ?? null;

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
                // Mostrar imagen actual si existe (solo en modo Quiz)
                if (currentMediaUrl != null &&
                    currentMediaUrl!.isNotEmpty &&
                    currentQ.type != 'true_false') ...[
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
                        currentMediaUrl!,
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
                        currentMediaUrl = null;
                        answer.mediaId = null;
                        answerImageUrls[answer.id] = null;
                      });
                      // Actualizar estado del widget principal
                      setState(() {
                        answer.mediaId = null;
                        answerImageUrls[answer.id] = null;
                      });
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar imagen'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                ],

                // En modo Verdadero/Falso, mostrar texto fijo en lugar de TextField editable
                if (currentQ.type == 'true_false')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          index == 0 ? 'Verdadero' : 'Falso',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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
                // Botón para subir imagen (solo en modo Quiz)
                if (currentMediaId == null && currentQ.type != 'true_false')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _uploadAnswerImage(index, setDialogState, answer),
                      icon: const Icon(Icons.image),
                      label: const Text('Subir imagen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                // Checkbox para marcar respuesta correcta
                if (currentQ.type == 'quiz' ||
                    currentQ.type == 'multiple' ||
                    currentQ.type == 'true_false') ...[
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
                      const Expanded(
                        child: Text('Marcar como respuesta correcta'),
                      ),
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
                  // En modo Verdadero/Falso, mantener el texto fijo
                  if (currentQ.type == 'true_false') {
                    answer.text = index == 0 ? 'Verdadero' : 'Falso';
                    answer.mediaId =
                        null; // No permitir imágenes en Verdadero/Falso
                  } else {
                    // Si hay imagen, limpiar texto
                    if (currentMediaId != null && currentMediaId!.isNotEmpty) {
                      answer.text = null;
                      answer.mediaId = currentMediaId;
                    } else {
                      // Si hay texto, limpiar imagen
                      answer.text = controller.text.trim().isEmpty
                          ? null
                          : controller.text.trim();
                      answer.mediaId = null;
                    }
                  }

                  // Si se marca como correcta, desmarcar todas las demás (solo para quiz y true_false, no para multiple)
                  if (isCorrect &&
                      (currentQ.type == 'quiz' ||
                          currentQ.type == 'true_false')) {
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

  Future<void> _uploadAnswerImage(
    int index,
    StateSetter setDialogState,
    AnswerData currentAnswer,
  ) async {
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
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final mediaService = ref.read(mediaServiceProvider);
        final file = File(image.path);
        final media = await mediaService.uploadMedia(file);

        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Cerrar indicador de carga
          // Actualizar estado del diálogo
          setDialogState(() {
            currentMediaId = media.assetId; // ID para backend
            currentMediaUrl = media.url; // URL para preview
            answerImageUrls[currentAnswer.id] = media.url; // URL para preview
          });
          // Actualizar estado del widget principal para forzar reconstrucción
          setState(() {
            currentMediaId = media.assetId; // ID para backend
            currentMediaUrl = media.url; // URL para preview
            answerImageUrls[currentAnswer.id] = media.url; // URL para preview
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Cerrar indicador de carga
          final errorMessage = e is AppException ? e.message : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imagen: $errorMessage')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AppException ? e.message : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $errorMessage')),
        );
      }
    }
  }

  Future<void> _uploadQuestionImage() async {
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
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final mediaService = ref.read(mediaServiceProvider);
        final file = File(image.path);
        final media = await mediaService.uploadMedia(file);

        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Cerrar indicador de carga
          final currentQ = currentQuestion;
          setState(() {
            currentQ.mediaId = media.assetId; // ID para backend
            questionImageUrls[currentQ.id] = media.url; // URL para preview
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen de pregunta subida exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Cerrar indicador de carga
          final errorMessage = e is AppException ? e.message : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imagen: $errorMessage')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AppException ? e.message : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $errorMessage')),
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
                  backgroundColor: isSelected
                      ? Colors.purple[600]
                      : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  elevation: isSelected ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '$time s',
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
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

  void _duplicateQuestion() {
    final currentQ = currentQuestion;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Duplicar todas las respuestas
    final duplicatedAnswers = currentQ.answers.map((answer) {
      return AnswerData(
        id: 'answer_${timestamp}_${answer.id}',
        text: answer.text,
        isCorrect: answer.isCorrect,
        mediaId: answer.mediaId,
      );
    }).toList();

    // Crear pregunta duplicada
    final duplicatedQuestion = QuestionData(
      id: 'question_${timestamp}_${questions.length}',
      text: currentQ.text,
      type: currentQ.type,
      timeLimit: currentQ.timeLimit,
      points: currentQ.points,
      mediaId: currentQ.mediaId,
      answers: duplicatedAnswers,
    );

    setState(() {
      // Copiar URL de imagen si existe
      if (currentQ.mediaId != null &&
          currentQ.mediaId!.isNotEmpty &&
          questionImageUrls[currentQ.id] != null) {
        questionImageUrls[duplicatedQuestion.id] =
            questionImageUrls[currentQ.id];
      }

      // Copiar URLs de imagenes de respuestas
      for (int i = 0; i < duplicatedAnswers.length; i++) {
        final originalAnswer = currentQ.answers[i];
        final duplicatedAnswer = duplicatedAnswers[i];
        if (originalAnswer.mediaId != null &&
            originalAnswer.mediaId!.isNotEmpty &&
            answerImageUrls[originalAnswer.id] != null) {
          answerImageUrls[duplicatedAnswer.id] =
              answerImageUrls[originalAnswer.id];
        }
      }

      // Insertar después de la pregunta actual
      questions.insert(currentQuestionIndex + 1, duplicatedQuestion);
      // Cambiar al índice de la pregunta duplicada
      currentQuestionIndex = currentQuestionIndex + 1;
    });
  }

  void _showPointsPicker(BuildContext context) {
    final currentQ = currentQuestion;
    final List<int> pointsOptions = [0, 1000, 2000];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar puntos'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: pointsOptions.map((points) {
              final isSelected = currentQ.points == points;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQ.points = points;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.purple[600]
                          : Colors.grey[200],
                      foregroundColor: isSelected
                          ? Colors.white
                          : Colors.black87,
                      elevation: isSelected ? 4 : 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '$points puntos',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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

  Future<void> _uploadQuizCoverImage(
    StateSetter setDialogState,
    Function(String?, String?) updateImage,
  ) async {
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
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final mediaService = ref.read(mediaServiceProvider);
        final file = File(image.path);
        final media = await mediaService.uploadMedia(file);

        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Cerrar indicador de carga
          setDialogState(() {
            updateImage(media.assetId, media.url);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen de portada subida exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Cerrar indicador de carga
          final errorMessage = e is AppException ? e.message : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imagen: $errorMessage')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AppException ? e.message : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $errorMessage')),
        );
      }
    }
  }

  void _showMetadataDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: quizTitle);
    final _descriptionController = TextEditingController(text: quizDescription);
    String? _selectedCategory = quizCategory.isNotEmpty ? quizCategory : null;
    String _selectedVisibility = quizVisibility;
    String? _dialogCoverImageId = quizCoverImageId;
    String? _dialogCoverImageUrl = quizCoverImageUrl;
    final categoriesAsync = ref.watch(categoryNamesProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Editar información del quiz'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Imagen de portada
                    Text(
                      'Imagen de portada (opcional)',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          _uploadQuizCoverImage(setDialogState, (id, url) {
                            _dialogCoverImageId = id;
                            _dialogCoverImageUrl = url;
                          }),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                          color: Colors.grey[50],
                        ),
                        child:
                            _dialogCoverImageUrl != null &&
                                _dialogCoverImageUrl!.isNotEmpty
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      _dialogCoverImageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 50,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setDialogState(() {
                                          _dialogCoverImageId = null;
                                          _dialogCoverImageUrl = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Toca para añadir imagen',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título del Quiz',
                        hintText: 'Ingresa el título de tu quiz',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describe tu quiz (opcional)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    // Categoría
                    categoriesAsync.when(
                      data: (categories) {
                        // Validar que la categoría seleccionada esté en la lista
                        if (_selectedCategory != null &&
                            !categories.contains(_selectedCategory)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setDialogState(() {
                                _selectedCategory = categories.isNotEmpty
                                    ? categories.first
                                    : null;
                              });
                            }
                          });
                        }
                        // Si no hay categoría seleccionada, seleccionar la primera
                        if (_selectedCategory == null &&
                            categories.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setDialogState(() {
                                _selectedCategory = categories.first;
                              });
                            }
                          });
                        }
                        return DropdownButtonFormField<String>(
                          value:
                              _selectedCategory != null &&
                                  categories.contains(_selectedCategory)
                              ? _selectedCategory
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La categoría es requerida';
                            }
                            return null;
                          },
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text(
                              'Error al cargar categorías',
                              style: TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () =>
                                  ref.invalidate(categoryNamesProvider),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Visibilidad
                    DropdownButtonFormField<String>(
                      value: _selectedVisibility,
                      decoration: const InputDecoration(
                        labelText: 'Visibilidad',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'private',
                          child: Text('Privado'),
                        ),
                        DropdownMenuItem(
                          value: 'public',
                          child: Text('Público'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            _selectedVisibility = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedCategory != null) {
                    setState(() {
                      quizTitle = _titleController.text.trim();
                      quizDescription = _descriptionController.text.trim();
                      quizCategory = _selectedCategory!;
                      quizVisibility = _selectedVisibility;
                      quizCoverImageId = _dialogCoverImageId;
                      quizCoverImageUrl = _dialogCoverImageUrl;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
