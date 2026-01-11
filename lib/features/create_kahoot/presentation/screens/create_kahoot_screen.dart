import 'dart:convert';
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
import 'package:frontkahoot2526/features/categories/presentation/providers/categories_provider.dart';

class CreateKahootScreen extends ConsumerStatefulWidget {
  const CreateKahootScreen({super.key});

  @override
  ConsumerState<CreateKahootScreen> createState() => _CreateKahootScreenState();
}

class _CreateKahootScreenState extends ConsumerState<CreateKahootScreen> {
  bool _isGenerating = false;

  Future<void> _showAIPromptDialog() async {
    print('Inició generación con IA');
    try {
      // Esperar a que se cargue la API key usando .future para obtener el Future real
      final apiKey = await ref.read(aiApiKeyProvider.future);

      if (apiKey == null || apiKey.isEmpty) {
        print('API Key no configurada. Mostrando diálogo de configuración');
        // Mostrar diálogo para configurar API key
        if (mounted) {
          _showApiKeyDialog();
        }
        return;
      }

      print('API Key configurada. Mostrando diálogo de prompt');
      // Continuar con el diálogo de prompt
      if (mounted) {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => const AIPromptDialog(),
        );

        if (result != null && mounted) {
          await _generateQuizWithAI(result);
        } else {
          print('Canceló el diálogo de prompt');
        }
      }
    } catch (error, stack) {
      print('ERROR al verificar API Key: ${error.toString()}');
      print('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                final url = Uri.parse(
                  'https://makersuite.google.com/app/apikey',
                );
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo abrir el enlace. Visita: https://makersuite.google.com/app/apikey',
                          ),
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
    print('Iniciando generación de quiz con IA');

    setState(() {
      _isGenerating = true;
    });

    try {
      // Verificar que el repositorio esté disponible
      print('Verificando repositorio');
      final repository = ref.read(aiQuizRepositoryProvider);
      if (repository == null) {
        print('ERROR Repositorio no disponible o API key no configurada');
        throw AppException(
          message:
              'API key no configurada. Por favor configura tu API key de Gemini.',
          statusCode: 401,
        );
      }
      print('Repositorio disponible');

      final aiService = AIQuizService(repository);
      print('Servicio creado, llamando a generateQuiz');

      final quiz = await aiService.generateQuiz(
        prompt: data['prompt'] as String,
        title: data['title'] as String,
        description: data['description'] as String,
        category: data['category'] as String,
        numberOfQuestions: data['numberOfQuestions'] as int,
      );

      print('Quiz generado exitosamente');

      if (mounted) {
        print('Convirtiendo preguntas a formato de URL');
        // Convertir las preguntas a formato que pueda usar from_scratch_screen
        // Formato: pregunta|tipo|tiempo|puntos|texto1~true;texto2~false;texto3~false;texto4~false
        // Se usa ~ como separador entre texto e isCorrect para evitar conflicto con | usado en las partes de la pregunta
        final questionsParam = quiz.questions
            .map((q) {
              final answersParam = q.answers
                  .map((a) {
                    return '${a.text ?? ""}~${a.isCorrect}';
                  })
                  .join(';');
              return '${q.text}|${q.type}|${q.timeLimit}|${q.points}|$answersParam';
            })
            .join('|||');

        // Codificar en base64 para evitar problemas con caracteres especiales
        print('Codificando preguntas en base64...');
        final questionsBase64 = base64Encode(utf8.encode(questionsParam));
        print(
          'Codificación base64 completada (${questionsBase64.length} caracteres)',
        );

        // Construir parámetros de URL
        final encodedTitle = Uri.encodeComponent(quiz.title);
        final encodedDescription = Uri.encodeComponent(quiz.description);
        final encodedCategory = Uri.encodeComponent(quiz.category);
        final encodedQuestions = Uri.encodeComponent(questionsBase64);

        print('Parámetros de URL a enviar:');
        print(
          '  - title: "${quiz.title}" (codificado: ${encodedTitle.length} caracteres)',
        );
        print(
          '  - description: "${quiz.description}" (codificado: ${encodedDescription.length} caracteres)',
        );
        print(
          '  - category: "${quiz.category}" (codificado: ${encodedCategory.length} caracteres)',
        );
        print('  - visibility: "${quiz.visibility}"');
        print('  - ai_generated: true');
        print(
          '  - questions (base64): ${questionsBase64.length} caracteres (codificado: ${encodedQuestions.length} caracteres)',
        );

        final url =
            '/create-kahoot/from-scratch?'
            'title=$encodedTitle&'
            'description=$encodedDescription&'
            'category=$encodedCategory&'
            'visibility=${quiz.visibility}&'
            'ai_generated=true&'
            'questions=$encodedQuestions';

        print('URL completa construida: $url');
        print('Navegando a pantalla de edición');
        context.go(url);
        print('Navegación completada');
      }
    } on AppException catch (e) {
      print('ERROR: ${e.message}');
      print('Status Code: ${e.statusCode}');
      if (e.error != null) {
        print('Detalles: ${e.error}');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('ERROR INESPERADO: ${e.toString()}');
      print('Tipo de error: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
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
        print('Proceso de generación finalizado');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color redBackground = const Color(0xFFF44336);
    final Color lightGray = Colors.grey[200]!;

    // Obtener categorías del backend
    final categoriesAsync = ref.watch(categoryNamesProvider);

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
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                          // proxima entrega
                          // SizedBox(
                          //   height: 50,
                          //   child: categoriesAsync.when(
                          //     data: (categories) => ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: categories.length,
                          //       itemBuilder: (context, index) {
                          //         final categoryName = categories[index];
                          //         return Padding(
                          //           padding: const EdgeInsets.only(right: 8),
                          //           child: ElevatedButton.icon(
                          //             onPressed: () {
                          //               // Filtrar por categoría
                          //             },
                          //             icon: const Icon(
                          //               Icons.category,
                          //               size: 20,
                          //             ),
                          //             label: Text(categoryName),
                          //             style: ElevatedButton.styleFrom(
                          //               backgroundColor: lightGray,
                          //               foregroundColor: Colors.black,
                          //               elevation: 0,
                          //               padding: const EdgeInsets.symmetric(
                          //                 horizontal: 16,
                          //                 vertical: 8,
                          //               ),
                          //               shape: RoundedRectangleBorder(
                          //                 borderRadius: BorderRadius.circular(20),
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     ),
                          //     loading: () => const Center(
                          //       child: CircularProgressIndicator(),
                          //     ),
                          //     error: (error, _) => Center(
                          //       child: Text(
                          //         'Error al cargar categorías',
                          //         style: TextStyle(color: Colors.grey[600]),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 16),
                          // Grid de plantillas
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
