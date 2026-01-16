import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/categories/presentation/providers/categories_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontkahoot2526/features/media/presentation/providers/media_service_provider.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/providers/quiz_preload_provider.dart';

class QuizMetadataScreen extends ConsumerStatefulWidget {
  const QuizMetadataScreen({super.key});

  @override
  ConsumerState<QuizMetadataScreen> createState() => _QuizMetadataScreenState();
}

class _QuizMetadataScreenState extends ConsumerState<QuizMetadataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String _selectedVisibility = 'private';
  String? quizCoverImageId; // ID para enviar al backend
  String? quizCoverImageUrl; // URL para mostrar preview

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          setState(() {
            quizCoverImageId = media.assetId; // ID para backend
            quizCoverImageUrl = media.url; // URL para preview
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

  void _navigateToFromScratch() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      // Crear QuizPreloadData con los metadatos (sin preguntas, lista vacía)
      final preloadData = QuizPreloadData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        visibility: _selectedVisibility,
        coverImageId: quizCoverImageId,
        coverImageUrl: quizCoverImageUrl,
        questions: const [], // Lista vacía para metadatos sin preguntas
        templateId: null,
        source: 'metadata',
      );

      // Guardar datos en el provider
      ref.read(quizPreloadProvider.notifier).setPreloadData(preloadData);

      // Navegar sin query params
      context.go('/create-kahoot/from-scratch');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryNamesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Información del Quiz',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _selectedCategory != null
                ? _navigateToFromScratch
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedCategory != null
                      ? Colors.black87
                      : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Continuar',
                style: TextStyle(
                  color: _selectedCategory != null
                      ? Colors.black87
                      : Colors.grey,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
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
                onTap: _uploadQuizCoverImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    color: Colors.grey[50],
                  ),
                  child:
                      quizCoverImageUrl != null && quizCoverImageUrl!.isNotEmpty
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                quizCoverImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
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
                                errorBuilder: (context, error, stackTrace) {
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
                                  setState(() {
                                    quizCoverImageId = null;
                                    quizCoverImageUrl = null;
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
                  // Si no hay categoría seleccionada, seleccionar la primera
                  if (_selectedCategory == null && categories.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedCategory = categories.first;
                        });
                      }
                    });
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
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
                        setState(() {
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
                        onPressed: () => ref.invalidate(categoryNamesProvider),
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
                  DropdownMenuItem(value: 'private', child: Text('Privado')),
                  DropdownMenuItem(value: 'public', child: Text('Público')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedVisibility = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
