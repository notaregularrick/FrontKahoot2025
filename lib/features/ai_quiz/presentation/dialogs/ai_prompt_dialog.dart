import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/categories/presentation/providers/categories_provider.dart';

class AIPromptDialog extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final String? initialCategory;

  const AIPromptDialog({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialCategory,
  });

  @override
  ConsumerState<AIPromptDialog> createState() => _AIPromptDialogState();
}

class _AIPromptDialogState extends ConsumerState<AIPromptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  int _numberOfQuestions = 5;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      Navigator.of(context).pop({
        'prompt': _promptController.text.trim(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'numberOfQuestions': _numberOfQuestions,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryNamesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purple[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Generar Quiz con IA',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tema/Prompt
                      TextFormField(
                        controller: _promptController,
                        decoration: const InputDecoration(
                          labelText: 'Tema del Quiz *',
                          hintText:
                              'Ej: Historia de México, Matemáticas básicas, Cultura pop...',
                          border: OutlineInputBorder(),
                          helperText:
                              'Describe el tema sobre el cual quieres que la IA genere preguntas',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El tema es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título del Quiz *',
                          hintText: 'Ej: Quiz de Historia de México',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El título es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Descripción opcional del quiz',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      // Categoría
                      categoriesAsync.when(
                        data: (categories) {
                          // Si no hay categoría seleccionada, seleccionar la primera
                          if (_selectedCategory == null &&
                              categories.isNotEmpty) {
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
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
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
                      const SizedBox(height: 16),
                      // Número de preguntas
                      const Text(
                        'Número de preguntas: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _numberOfQuestions.toDouble(),
                              min: 3,
                              max: 10,
                              divisions: 7,
                              label: '$_numberOfQuestions preguntas',
                              onChanged: (value) {
                                setState(() {
                                  _numberOfQuestions = value.toInt();
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              '$_numberOfQuestions',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedCategory != null ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        SizedBox(width: 8),
                        Text('Generar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
