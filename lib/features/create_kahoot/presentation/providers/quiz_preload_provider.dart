import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Datos precargados de un quiz antes de navegar a from_scratch_screen
class QuizPreloadData {
  final String title;
  final String description;
  final String category;
  final String visibility;
  final String? coverImageId;
  final String? coverImageUrl;
  final List<PreloadedQuestion> questions;
  final String? templateId; // Para templates
  final String source; // 'template' | 'ai'

  const QuizPreloadData({
    required this.title,
    required this.description,
    required this.category,
    required this.visibility,
    this.coverImageId,
    this.coverImageUrl,
    required this.questions,
    this.templateId,
    required this.source,
  });
}

/// Pregunta precargada
class PreloadedQuestion {
  final String text;
  final String type;
  final int timeLimit;
  final int points;
  final List<PreloadedAnswer> answers;

  const PreloadedQuestion({
    required this.text,
    required this.type,
    required this.timeLimit,
    required this.points,
    required this.answers,
  });
}

/// Respuesta precargada
class PreloadedAnswer {
  final String? text;
  final bool isCorrect;

  const PreloadedAnswer({
    this.text,
    required this.isCorrect,
  });
}

/// Estado del provider (null cuando no hay datos precargados)
class QuizPreloadState {
  final QuizPreloadData? data;

  const QuizPreloadState({this.data});

  bool get hasData => data != null;
}

/// Notifier que gestiona el estado de datos precargados
class QuizPreloadNotifier extends StateNotifier<QuizPreloadState> {
  QuizPreloadNotifier() : super(const QuizPreloadState());

  /// Establece los datos precargados
  void setPreloadData(QuizPreloadData data) {
    state = QuizPreloadState(data: data);
  }

  /// Obtiene y limpia los datos precargados
  /// Retorna null si no hay datos
  QuizPreloadData? consumePreloadData() {
    final data = state.data;
    if (data != null) {
      state = const QuizPreloadState();
    }
    return data;
  }

  /// Limpia los datos precargados sin leerlos
  void clear() {
    state = const QuizPreloadState();
  }
}

/// Provider del notifier
final quizPreloadProvider =
    StateNotifierProvider<QuizPreloadNotifier, QuizPreloadState>((ref) {
  return QuizPreloadNotifier();
});

