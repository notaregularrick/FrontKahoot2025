import 'package:flutter/material.dart';

class AIPromptDialog extends StatefulWidget {
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
  State<AIPromptDialog> createState() => _AIPromptDialogState();
}

class _AIPromptDialogState extends State<AIPromptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Estudio';
  int _numberOfQuestions = 5;

  final List<String> categories = [
    'Estudio',
    'Familia',
    'Noche de juegos',
    'Celebración',
    'Proyectos',
    'Calentamiento',
    'Trivia',
    'De temporada',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _selectedCategory = widget.initialCategory ?? 'Estudio';
  }

  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                  Icon(Icons.auto_awesome, color: Colors.purple[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Generar Quiz con IA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
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
                          hintText: 'Ej: Historia de México, Matemáticas básicas, Cultura pop...',
                          border: OutlineInputBorder(),
                          helperText: 'Describe el tema sobre el cual quieres que la IA genere preguntas',
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
                      DropdownButtonFormField<String>(
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
                      ),
                      const SizedBox(height: 16),
                      // Número de preguntas
                      Row(
                        children: [
                          const Text(
                            'Número de preguntas: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
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
                    onPressed: _submit,
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


