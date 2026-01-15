import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../state/quiz_state.dart';

class QuizDetailNotifier extends StateNotifier<QuizDetailState> {
  final QuizRepository _repository;
  final String quizId;

  // Constructor inteligente
  QuizDetailNotifier(this._repository, this.quizId, {QuizEntity? initialQuiz}) 
      : super(QuizDetailState(
          // Si nos pasan el quiz, NO cargamos. Si es null, sí cargamos.
          isLoading: initialQuiz == null, 
          quiz: initialQuiz,
        )) {
    
    // Si NO nos pasaron el quiz (ej. recargar página web), intentamos buscarlo.
    // (Nota: Esto fallará con la excepción que pusimos en el Datasource, lo cual es correcto).
    if (initialQuiz == null) {
      _loadQuiz();
    }
  }

  Future<void> _loadQuiz() async {
    state = state.copyWith(isLoading: true);
    try {
      final quiz = await _repository.getQuizDetail(quizId);
      state = state.copyWith(isLoading: false, quiz: quiz);
    } catch (e) {
      // Capturamos el error controlado del datasource
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }
  
  Future<void> refresh() async {
    // Si refrescamos, intentamos pedirlo de nuevo (fallará, pero es la acción lógica)
    await _loadQuiz();
  }
}

// Parámetros para identificar el provider único
class QuizDetailFamilyParams {
  final String id;
  final QuizEntity? quiz; // El objeto completo pasado por navegación

  QuizDetailFamilyParams({required this.id, this.quiz});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizDetailFamilyParams &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}