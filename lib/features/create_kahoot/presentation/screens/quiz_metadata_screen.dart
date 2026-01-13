import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/categories/presentation/providers/categories_provider.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _navigateToFromScratch() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      // Pasar metadata a la pantalla from-scratch mediante parámetros de consulta
      context.go(
        '/create-kahoot/from-scratch?title=${Uri.encodeComponent(_titleController.text)}&description=${Uri.encodeComponent(_descriptionController.text)}&category=${Uri.encodeComponent(_selectedCategory!)}&visibility=$_selectedVisibility',
      );
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
            onPressed: _selectedCategory != null ? _navigateToFromScratch : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedCategory != null ? Colors.black87 : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Continuar',
                style: TextStyle(
                  color: _selectedCategory != null ? Colors.black87 : Colors.grey,
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
