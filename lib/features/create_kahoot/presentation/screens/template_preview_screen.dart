import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/quiz_template.dart';
import '../../data/predefined_templates.dart';

/// Pantalla de vista previa de una plantilla
/// Muestra la información completa de la plantilla y permite personalizarla
class TemplatePreviewScreen extends ConsumerWidget {
  final String templateId;

  const TemplatePreviewScreen({
    super.key,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Buscar la plantilla por ID
    final template = predefinedTemplates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => predefinedTemplates.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de volver
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Vista previa',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagen de portada
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildCoverImage(template),
                    ),

                    const SizedBox(height: 24),

                    // Título
                    Text(
                      template.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      template.description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info badges
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildInfoBadge(
                          icon: Icons.quiz,
                          text: '${template.questionCount} preguntas',
                          template: template,
                        ),
                        _buildInfoBadge(
                          icon: Icons.category,
                          text: template.category,
                          template: template,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sección de preguntas
                    const Text(
                      'Vista previa de preguntas',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lista de preguntas
                    ...template.questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return _buildQuestionPreview(index, question, template);
                    }),

                    const SizedBox(height: 100), // Espacio para el botón
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Botón flotante de personalizar
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToEditor(context, template),
          backgroundColor: Colors.purple[600],
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
          ),
          label: const Text(
            'Personalizar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Construye la imagen de portada
  Widget _buildCoverImage(QuizTemplate template) {
    if (template.coverImagePath != null) {
      return Image.asset(
        template.coverImagePath!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover(template);
        },
      );
    }
    return _buildPlaceholderCover(template);
  }

  /// Placeholder cuando no hay imagen
  Widget _buildPlaceholderCover(QuizTemplate template) {
    final emoji = template.title.split(' ').first;
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  /// Construye un badge de información
  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
    required QuizTemplate template,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la vista previa de una pregunta
  Widget _buildQuestionPreview(int index, TemplateQuestion question, QuizTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número y tipo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getQuestionTypeLabel(question.type),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.timer,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${question.timeLimit}s',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.star,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${question.points}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Texto de la pregunta
          Text(
            question.text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          if (question.imagePath != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.image,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Con imagen',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Obtiene la etiqueta del tipo de pregunta
  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'quiz':
        return 'Selección única';
      case 'multiple':
        return 'Selección múltiple';
      case 'true_false':
        return 'Verdadero/Falso';
      default:
        return 'Quiz';
    }
  }

  /// Navega al editor con los datos de la plantilla precargados
  void _navigateToEditor(BuildContext context, QuizTemplate template) {

    final questionsParam = template.questions.map((q) {
      final answersParam = q.answers.map((a) {
        return '${a.text}~${a.isCorrect}';
      }).join(';');
      return '${q.text}|${q.type}|${q.timeLimit}|${q.points}|$answersParam';
    }).join('|||');

    // Codificar en base64
    final questionsBase64 = base64Encode(utf8.encode(questionsParam));

    // Construir URL con parámetros
    final encodedTitle = Uri.encodeComponent(template.title);
    final encodedDescription = Uri.encodeComponent(template.description);
    final encodedCategory = Uri.encodeComponent(template.category);
    final encodedQuestions = Uri.encodeComponent(questionsBase64);

    final url = '/create-kahoot/from-scratch?'
        'title=$encodedTitle&'
        'description=$encodedDescription&'
        'category=$encodedCategory&'
        'visibility=private&'
        'template=true&'
        'template_id=${template.id}&'
        'questions=$encodedQuestions';

    context.go(url);
  }
}

