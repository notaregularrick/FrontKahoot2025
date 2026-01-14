import 'dart:convert';
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
  String? _defaultThemeId;

  @override
  void initState() {
    super.initState();
    // Inicializar con la primera pregunta
    _addNewQuestion();
    // Cargar themeId del backend
    _loadDefaultTheme();
  }

  Future<void> _loadDefaultTheme() async {
    try {
      final mediaService = ref.read(mediaServiceProvider);
      final themes = await mediaService.getThemes();
      if (themes.isNotEmpty && mounted) {
        setState(() {
          _defaultThemeId = themes.first.assetId;
        });
        print('[FROM SCRATCH] Theme cargado: $_defaultThemeId');
      }
    } catch (e) {
      print('[FROM SCRATCH] Error al cargar themes: $e');
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
        print('[FROM SCRATCH] MediaId recibido sin URL: $mediaId');
        // No establecemos quizCoverImageUrl para que el usuario pueda subir una nueva imagen si lo desea
      }
    } catch (e) {
      print('[FROM SCRATCH] Error al cargar URL de imagen de portada: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = GoRouterState.of(context);
    final uri = route.uri;
    final queryParams = uri.queryParameters;
    
      if (quizTitle.isEmpty && queryParams.isNotEmpty) {
        print('Parámetros de URL recibidos:');
        print('  - title: "${queryParams['title']}" (${queryParams['title']?.length ?? 0} caracteres)');
        print('  - description: "${queryParams['description']}" (${queryParams['description']?.length ?? 0} caracteres)');
        print('  - category: "${queryParams['category']}" (${queryParams['category']?.length ?? 0} caracteres)');
        print('  - visibility: "${queryParams['visibility']}"');
        print('  - ai_generated: "${queryParams['ai_generated']}"');
        print('  - coverImageId: "${queryParams['coverImageId']}"');
        print('  - questions: ${queryParams['questions']?.length ?? 0} caracteres');
        if (queryParams['questions'] != null && queryParams['questions']!.length > 0) {
          final questionsPreview = queryParams['questions']!.substring(0, queryParams['questions']!.length > 100 ? 100 : queryParams['questions']!.length);
          print('  - questions (preview): $questionsPreview${queryParams['questions']!.length > 100 ? '...' : ''}');
        }
        print('URI completa: ${uri.toString()}');
        
        setState(() {
          quizTitle = Uri.decodeComponent(queryParams['title'] ?? '');
          quizDescription = Uri.decodeComponent(queryParams['description'] ?? '');
          quizCategory = Uri.decodeComponent(queryParams['category'] ?? 'Estudio');
          quizVisibility = queryParams['visibility'] ?? 'private';
          
          // Cargar coverImageId y coverImageUrl si vienen en los parámetros
          if (queryParams['coverImageId'] != null && queryParams['coverImageId']!.isNotEmpty) {
            quizCoverImageId = Uri.decodeComponent(queryParams['coverImageId']!);
            // Si también viene la URL, usarla directamente
            if (queryParams['coverImageUrl'] != null && queryParams['coverImageUrl']!.isNotEmpty) {
              quizCoverImageUrl = Uri.decodeComponent(queryParams['coverImageUrl']!);
            } else {
              // Si no viene la URL, intentar construirla desde el ID
              _loadCoverImageUrl(quizCoverImageId!);
            }
          }
          
          print('Parámetros decodificados:');
          print('  - title decodificado: "$quizTitle"');
          print('  - description decodificada: "$quizDescription"');
          print('  - category decodificada: "$quizCategory"');
          print('  - visibility: "$quizVisibility"');
          print('  - coverImageId: "$quizCoverImageId"');
          
          // Si viene de IA o de plantilla, cargar las preguntas precargadas
          if ((queryParams['ai_generated'] == 'true' || queryParams['template'] == 'true') && queryParams['questions'] != null) {
            final source = queryParams['template'] == 'true' ? 'plantilla' : 'IA';
            print('Detectado quiz de $source - Cargando preguntas...');
            _loadAIGeneratedQuestions(queryParams['questions']!);
          }
        });
      }
  }

  void _loadAIGeneratedQuestions(String questionsParam) {
    print('[FROM SCRATCH] Cargando preguntas generadas por IA...');
    print('[FROM SCRATCH] Parámetro questions recibido:');
    print('[FROM SCRATCH]   - Tamaño: ${questionsParam.length} caracteres');
    if (questionsParam.length > 0) {
      final preview = questionsParam.substring(0, questionsParam.length > 150 ? 150 : questionsParam.length);
      print('[FROM SCRATCH]   - Preview (primeros 150 caracteres): $preview${questionsParam.length > 150 ? '...' : ''}');
    }
    
    try {
      print('[FROM SCRATCH] Paso 1: Decodificando parámetro de URL...');
      final urlDecoded = Uri.decodeComponent(questionsParam);
      print('[FROM SCRATCH]   - Tamaño después de URL decode: ${urlDecoded.length} caracteres');
      if (urlDecoded.length > 0) {
        final urlPreview = urlDecoded.substring(0, urlDecoded.length > 100 ? 100 : urlDecoded.length);
        print('[FROM SCRATCH]   - Preview URL decoded: $urlPreview${urlDecoded.length > 100 ? '...' : ''}');
      }
      
      print('[FROM SCRATCH] Paso 2: Decodificando desde base64...');
      final base64Decoded = base64Decode(urlDecoded);
      print('[FROM SCRATCH]   - Tamaño después de base64 decode: ${base64Decoded.length} bytes');
      
      print('[FROM SCRATCH] Paso 3: Convirtiendo bytes a string UTF-8...');
      final decodedQuestions = utf8.decode(base64Decoded);
      print('[FROM SCRATCH]   - Tamaño final del string: ${decodedQuestions.length} caracteres');
      if (decodedQuestions.length > 0) {
        final finalPreview = decodedQuestions.substring(0, decodedQuestions.length > 200 ? 200 : decodedQuestions.length);
        print('[FROM SCRATCH]   - Preview final: $finalPreview${decodedQuestions.length > 200 ? '...' : ''}');
      }
      
      print('[FROM SCRATCH] Separando preguntas...');
      final questionsList = decodedQuestions.split('|||');
      print('[FROM SCRATCH] Preguntas recibidas: ${questionsList.length}');
      
      questions.clear(); // Limpiar preguntas iniciales
      print('[FROM SCRATCH] Preguntas anteriores limpiadas');
      
      for (int i = 0; i < questionsList.length; i++) {
        print('[FROM SCRATCH] Procesando pregunta ${i + 1}/${questionsList.length}...');
        
        final questionParts = questionsList[i].split('|');
        print('[FROM SCRATCH] Partes encontradas: ${questionParts.length}');
        
        if (questionParts.length >= 4) {
          final questionText = questionParts[0];
          final questionType = questionParts[1];
          final timeLimit = int.tryParse(questionParts[2]) ?? 20;
          final points = int.tryParse(questionParts[3]) ?? 1000;
          
          print('[FROM SCRATCH] Texto: "${questionText.substring(0, questionText.length > 30 ? 30 : questionText.length)}${questionText.length > 30 ? '...' : ''}"');
          print('[FROM SCRATCH] Tipo: $questionType');
          print('[FROM SCRATCH] Tiempo límite: $timeLimit segundos');
          print('[FROM SCRATCH] Puntos: $points');
          
          final answers = <AnswerData>[];
          if (questionParts.length > 4) {
            print('[FROM SCRATCH] Procesando respuestas...');
            final answersList = questionParts[4].split(';');
            print('[FROM SCRATCH] Respuestas encontradas: ${answersList.length}');
            
            for (int j = 0; j < answersList.length; j++) {
              // Validar que la respuesta no esté vacía
              if (answersList[j].trim().isEmpty) {
                print('[FROM SCRATCH] Respuesta $j ignorada (vacía)');
                continue;
              }
              
              // Usar ~ como separador entre texto e isCorrect (evita conflicto con | usado en partes de pregunta)
              final answerParts = answersList[j].split('~');
              if (answerParts.length >= 2) {
                final answerText = answerParts[0].isEmpty ? null : answerParts[0].trim();
                final isCorrect = answerParts[1].trim() == 'true';
                
                // Validar que la respuesta tenga al menos texto (mediaId se maneja después)
                // Para true/false, permitir respuestas sin texto ya que se completarán después
                if (answerText == null || answerText.isEmpty) {
                  if (questionType != 'true_false') {
                    print('[FROM SCRATCH] Respuesta $j ignorada (sin texto ni mediaId)');
                    continue;
                  }
                }
                
                final answerPreview = answerText != null 
                    ? answerText.substring(0, answerText.length > 20 ? 20 : answerText.length) + (answerText.length > 20 ? '...' : '')
                    : 'null';
                print('[FROM SCRATCH]          Respuesta $j: "$answerPreview" (Correcta: $isCorrect)');
              
                answers.add(AnswerData(
                  id: 'answer_${i}_$j',
                  text: answerText,
                  isCorrect: isCorrect,
                  mediaId: null,
                ));
              } else {
                print('[FROM SCRATCH] Respuesta $j ignorada (formato inválido - se requieren al menos 2 partes, encontradas: ${answerParts.length})');
              }
            }
          } else {
            print('[FROM SCRATCH] No se encontraron respuestas para esta pregunta');
          }
          
          // Validar y completar respuestas según el tipo de pregunta
          final requiredAnswers = questionType == 'true_false' ? 2 : 4;
          final minRequiredAnswers = questionType == 'true_false' ? 2 : 2;
          
          print('[FROM SCRATCH] Validando respuestas: ${answers.length} encontradas, ${requiredAnswers} requeridas');
          
          // Completar respuestas faltantes
          while (answers.length < requiredAnswers) {
            if (questionType == 'true_false') {
              // Para true/false, agregar "Verdadero" o "Falso"
              answers.add(AnswerData(
                id: 'answer_${i}_${answers.length}',
                text: answers.length == 0 ? 'Verdadero' : 'Falso',
                isCorrect: false,
                mediaId: null,
              ));
              print('[FROM SCRATCH] Respuesta ${answers.length} agregada automáticamente (true/false)');
            } else {
              // Para quiz, agregar respuestas vacías
              answers.add(AnswerData(
                id: 'answer_${i}_${answers.length}',
                text: null,
                isCorrect: false,
                mediaId: null,
              ));
              print('[FROM SCRATCH] Respuesta ${answers.length} agregada automáticamente (quiz vacía)');
            }
          }
          
          // Solo agregar la pregunta si tiene al menos el mínimo requerido
          if (answers.length >= minRequiredAnswers) {
            questions.add(QuestionData(
              id: 'question_$i',
              text: questionText,
              type: questionType,
              timeLimit: timeLimit,
              points: points,
              mediaId: null,
              answers: answers,
            ));
            
            print('[FROM SCRATCH] Pregunta ${i + 1} cargada exitosamente (${answers.length} respuestas)');
          } else {
            print('[FROM SCRATCH] Pregunta ${i + 1} ignorada (no tiene suficientes respuestas: ${answers.length} < $minRequiredAnswers)');
          }
        } else {
          print('[FROM SCRATCH] Pregunta ${i + 1} ignorada (formato inválido - se requieren al menos 4 partes)');
        }
      }
      
      print('[FROM SCRATCH] Total preguntas cargadas: ${questions.length}');
      
      if (questions.isNotEmpty) {
        currentQuestionIndex = 0;
        print('[FROM SCRATCH] Índice de pregunta actual establecido en 0');
      } else {
        print('[FROM SCRATCH] No se pudieron cargar preguntas - Creando pregunta por defecto');
        // Si no se pudieron cargar preguntas, mantener las por defecto
        if (questions.isEmpty) {
          _addNewQuestion();
        }
      }
    } on FormatException catch (e) {
      print('[FROM SCRATCH] ERROR: Error al decodificar base64: ${e.toString()}');
      print('[FROM SCRATCH] CAUSA: El formato base64 es inválido o está corrupto');
      print('[FROM SCRATCH] Parámetro recibido (primeros 100 caracteres): ${questionsParam.substring(0, questionsParam.length > 100 ? 100 : questionsParam.length)}');
      
      // Si hay error al parsear, mantener las preguntas por defecto
      if (questions.isEmpty) {
        print('[FROM SCRATCH] Creando pregunta por defecto debido al error de base64');
        _addNewQuestion();
      }
    } on ArgumentError catch (e) {
      print('[FROM SCRATCH] ERROR: Error de codificación URI: ${e.toString()}');
      print('[FROM SCRATCH] CAUSA: El parámetro de URL tiene codificación inválida');
      print('[FROM SCRATCH] Parámetro recibido (primeros 100 caracteres): ${questionsParam.substring(0, questionsParam.length > 100 ? 100 : questionsParam.length)}');
      
      // Si hay error al parsear, mantener las preguntas por defecto
      if (questions.isEmpty) {
        print('[FROM SCRATCH] Creando pregunta por defecto debido al error de URI');
        _addNewQuestion();
      }
    } catch (e, stackTrace) {
      print('[FROM SCRATCH] ERROR al cargar preguntas: ${e.toString()}');
      print('[FROM SCRATCH] Tipo de error: ${e.runtimeType}');
      print('[FROM SCRATCH] Stack trace: $stackTrace');
      
      // Si hay error al parsear, mantener las preguntas por defecto
      if (questions.isEmpty) {
        print('[FROM SCRATCH] Creando pregunta por defecto debido al error');
        _addNewQuestion();
      }
    }
  }

  void _addNewQuestion() {
    setState(() {
      final questionType = _mapQuizTypeToQuestionType(selectedQuizType);
      final isTrueFalse = questionType == 'true_false';
      
      questions.add(QuestionData(
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
      ));
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
        const SnackBar(content: Text('Error: No se pudo cargar el tema. Intenta de nuevo.')),
      );
      // Intentar cargar el theme de nuevo
      await _loadDefaultTheme();
      return;
    }

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
      
      // Validar que para selección múltiple haya al menos 2 respuestas correctas
      if (question.type == 'multiple') {
        final correctAnswersCount = validAnswers.where((a) => a.isCorrect).length;
        if (correctAnswersCount < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Las preguntas de selección múltiple deben tener al menos 2 respuestas correctas')),
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
        points: q.points,
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
          SnackBar(content: Text('Quiz "${createdQuiz.title}" creado exitosamente')),
        );
        context.go('/create-kahoot');
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el quiz: ${e.message}')),
        );
        print('Error al crear el quiz: ${e.message}');
        print('Error al crear el quiz: ${e.statusCode}');
        print('Error al crear el quiz: ${e.error}');  
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
                  const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 20),
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
            const PopupMenuItem(value: 'Selección Múltiple', child: Text('Selección Múltiple')),
            const PopupMenuItem(value: 'Verdadero/Falso', child: Text('Verdadero/Falso')),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'duplicate') {
                _duplicateQuestion();
              } else if (value == 'points') {
                _showPointsPicker(context);
              }
            },
            itemBuilder: (context) => [
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
            // Botón Añadir multimedia y tiempo
            Row(
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 200),
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
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 92,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Mostrar imagen de portada si existe
            if (quizCoverImageUrl != null && quizCoverImageUrl!.isNotEmpty) ...[
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
                        quizCoverImageUrl!,
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
                          quizCoverImageUrl = null;
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
              children: List.generate(
                currentQ.type == 'true_false' ? 2 : 4,
                (index) {
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
                  final hasText = answer.text != null && answer.text!.trim().isNotEmpty;
                  final hasImage = answer.mediaId != null && answer.mediaId!.isNotEmpty;
                  String label;
                  if (hasText) {
                    label = answer.text!;
                  } else if (currentQ.type == 'true_false') {
                    label = index == 0 ? 'Verdadero' : 'Falso';
                  } else {
                    label = index < 2 ? 'Añadir respuesta' : 'Añadir respuesta (opcional)';
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
                },
              ),
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
            child: hasImage && currentQ.type != 'true_false'
                ? Image.network(
                    answer.mediaId!,
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
        if ((hasText || hasImage) && (currentQ.type == 'quiz' || currentQ.type == 'multiple' || currentQ.type == 'true_false'))
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
                // Mostrar imagen actual si existe (solo en modo Quiz)
                if (currentMediaUrl != null && currentMediaUrl!.isNotEmpty && currentQ.type != 'true_false') ...[
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
                if (currentQ.type == 'quiz' || currentQ.type == 'multiple' || currentQ.type == 'true_false') ...[
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
                  // En modo Verdadero/Falso, mantener el texto fijo
                  if (currentQ.type == 'true_false') {
                    answer.text = index == 0 ? 'Verdadero' : 'Falso';
                    answer.mediaId = null; // No permitir imágenes en Verdadero/Falso
                  } else {
                    // Si hay imagen, limpiar texto
                    if (currentMediaId != null && currentMediaId!.isNotEmpty) {
                      answer.text = null;
                      answer.mediaId = currentMediaId;
                    } else {
                      // Si hay texto, limpiar imagen
                      answer.text = controller.text.trim().isEmpty ? null : controller.text.trim();
                      answer.mediaId = null;
                    }
                  }
                  
                  // Si se marca como correcta, desmarcar todas las demás (solo para quiz y true_false, no para multiple)
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
            quizCoverImageId = media.assetId; // ID para backend
            quizCoverImageUrl = media.url; // URL para preview
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen de portada subida exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar indicador de carga
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
          // Actualizar estado del diálogo
          setDialogState(() {
            currentMediaId = media.assetId; // ID para backend
            currentMediaUrl = media.url; // URL para preview
          });
          // Actualizar estado del widget principal para forzar reconstrucción
          setState(() {
            currentMediaId = media.assetId; // ID para backend
            currentMediaUrl = media.url; // URL para preview
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar indicador de carga
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
                      backgroundColor: isSelected ? Colors.purple[600] : Colors.grey[200],
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      elevation: isSelected ? 4 : 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '$points puntos',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
}
