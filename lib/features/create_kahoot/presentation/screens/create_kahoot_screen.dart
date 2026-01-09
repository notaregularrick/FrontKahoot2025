import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontkahoot2526/features/ai_quiz/presentation/dialogs/ai_prompt_dialog.dart';
import 'package:frontkahoot2526/features/ai_quiz/presentation/providers/ai_quiz_repository_provider.dart';
import 'package:frontkahoot2526/features/ai_quiz/presentation/providers/ai_api_key_provider.dart';
import 'package:frontkahoot2526/features/ai_quiz/application/ai_quiz_service.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/core/providers/secure_storage_provider.dart';

class CreateKahootScreen extends ConsumerStatefulWidget {
  const CreateKahootScreen({super.key});

  @override
  ConsumerState<CreateKahootScreen> createState() => _CreateKahootScreenState();
}

class _CreateKahootScreenState extends ConsumerState<CreateKahootScreen> {
  bool _isGenerating = false;

  Future<void> _showAIPromptDialog() async {
    // Verificar si la API key está configurada
    final apiKeyAsync = ref.read(aiApiKeyProvider);
    await apiKeyAsync.when(
      data: (apiKey) async {
        if (apiKey == null || apiKey.isEmpty) {
          // Mostrar diálogo para configurar API key
          if (mounted) {
            _showApiKeyDialog();
          }
          return;
        }
        // Continuar con el diálogo de prompt
        if (mounted) {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => const AIPromptDialog(),
          );

          if (result != null && mounted) {
            await _generateQuizWithAI(result);
          }
        }
      },
      loading: () {
        // Mostrar loading mientras se verifica la API key
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verificando configuración...'),
            ),
          );
        }
      },
      error: (error, stack) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showApiKeyDialog() {
    final apiKeyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key, color: Colors.purple),
            SizedBox(width: 8),
            Text('Configurar API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Para usar la generación con IA, necesitas una API key de Google Gemini.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Ingresa tu API key de Gemini',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final url = Uri.parse('https://makersuite.google.com/app/apikey');
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el enlace. Visita: https://makersuite.google.com/app/apikey'),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al abrir el enlace: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Obtener API key en Google AI Studio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (apiKeyController.text.trim().isNotEmpty) {
                final storage = ref.read(secureStorageProvider);
                await storage.saveGeminiApiKey(apiKeyController.text.trim());
                if (mounted) {
                  Navigator.of(context).pop();
                  // Refrescar el provider
                  ref.invalidate(aiApiKeyProvider);
                  // Esperar un momento para que el provider se actualice
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) {
                    // Mostrar diálogo de prompt
                    _showAIPromptDialog();
                  }
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateQuizWithAI(Map<String, dynamic> data) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Verificar que el repositorio esté disponible
      final repository = ref.read(aiQuizRepositoryProvider);
      if (repository == null) {
        throw AppException(
          message: 'API key no configurada. Por favor configura tu API key de Gemini.',
          statusCode: 401,
        );
      }
      
      final aiService = AIQuizService(repository);
      
      final quiz = await aiService.generateQuiz(
        prompt: data['prompt'] as String,
        title: data['title'] as String,
        description: data['description'] as String,
        category: data['category'] as String,
        numberOfQuestions: data['numberOfQuestions'] as int,
      );

      if (mounted) {
        // Convertir las preguntas a formato que pueda usar from_scratch_screen
        final questionsParam = quiz.questions.map((q) {
          final answersParam = q.answers.map((a) {
            return '${a.text ?? ""}|${a.isCorrect}';
          }).join(';');
          return '${q.text}|${q.type}|${q.timeLimit}|${q.points}|$answersParam';
        }).join('|||');

        context.go(
          '/create-kahoot/from-scratch?'
          'title=${Uri.encodeComponent(quiz.title)}&'
          'description=${Uri.encodeComponent(quiz.description)}&'
          'category=${Uri.encodeComponent(quiz.category)}&'
          'visibility=${quiz.visibility}&'
          'ai_generated=true&'
          'questions=${Uri.encodeComponent(questionsParam)}',
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color redBackground = const Color(0xFFF44336);
    final Color lightGray = Colors.grey[200]!;

    final List<Map<String, dynamic>> categories = [
      {'name': 'Estudio', 'icon': Icons.school},
      {'name': 'Familia', 'icon': Icons.family_restroom},
      {'name': 'Noche de juegos', 'icon': Icons.sports_esports},
      {'name': 'Celebración', 'icon': Icons.celebration},
      {'name': 'Proyectos', 'icon': Icons.work},
      {'name': 'Calentamiento', 'icon': Icons.local_fire_department},
      {'name': 'Trivia', 'icon': Icons.quiz},
      {'name': 'De temporada', 'icon': Icons.calendar_today},
      {'name': 'Social', 'icon': Icons.people},
    ];

    return Scaffold(
      backgroundColor: redBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Crear',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crea tú mismo',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              context.go('/create-kahoot/quiz-metadata');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: lightGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.purple[600],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 4,
                                          top: 4,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.purple[400],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const Positioned(
                                          right: 4,
                                          bottom: 4,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Lienzos en blanco',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Toma el control total de la creación de kahoots',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Botón Generar con IA
                          GestureDetector(
                            onTap: _isGenerating ? null : _showAIPromptDialog,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.purple[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.purple[600],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _isGenerating
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Generar con IA',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _isGenerating
                                              ? 'Generando tu quiz...'
                                              : 'Deja que la IA cree tu quiz completo',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sección "Plantillas"
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con "Plantillas" y "Ver todos"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Plantillas',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Ver todas las plantillas
                                },
                                child: const Text(
                                  'Ver todos',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Carrusel de categorías
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Filtrar por categoría
                                    },
                                    icon: Icon(
                                      category['icon'] as IconData,
                                      size: 20,
                                    ),
                                    label: Text(category['name'] as String),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: lightGray,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Grid de plantillas
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: lightGray,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header de la plantilla
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Plantilla',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Área de imagen/preview (blanco)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
