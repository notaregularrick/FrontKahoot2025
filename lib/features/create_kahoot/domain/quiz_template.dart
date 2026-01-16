import 'package:flutter/material.dart';

/// Modelo que representa una plantilla de quiz predefinida
class QuizTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  
  /// Path de la imagen de portada en assets (ej: 'assets/templates/halloween/cover.png')
  final String? coverImagePath;
  
  /// Colores para la experiencia visual del editor
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;
  
  /// Preguntas predefinidas
  final List<TemplateQuestion> questions;

  const QuizTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.coverImagePath,
    required this.backgroundColor,
    required this.buttonColor,
    this.textColor = Colors.white,
    required this.questions,
  });
  
  /// Número de preguntas en la plantilla
  int get questionCount => questions.length;
}

/// Modelo que representa una pregunta en una plantilla
class TemplateQuestion {
  final String text;
  final String type; // 'quiz', 'true_false', 'multiple'
  final int timeLimit;
  final int points;
  
  /// Path de la imagen de la pregunta en assets (opcional)
  final String? imagePath;
  
  /// Respuestas de la pregunta
  final List<TemplateAnswer> answers;

  const TemplateQuestion({
    required this.text,
    this.type = 'quiz',
    this.timeLimit = 20,
    this.points = 1000,
    this.imagePath,
    required this.answers,
  });
}

/// Modelo que representa una respuesta en una plantilla
class TemplateAnswer {
  final String text;
  final bool isCorrect;
  
  /// Path de la imagen de la respuesta en assets (opcional)
  final String? imagePath;

  const TemplateAnswer({
    required this.text,
    required this.isCorrect,
    this.imagePath,
  });
}

