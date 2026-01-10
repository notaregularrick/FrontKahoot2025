import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../state/quiz_state.dart';

class QuizDetailNotifier extends StateNotifier<QuizDetailState> {
  final QuizRepository _repository; // Usamos el repositorio
  final String quizId;

  QuizDetailNotifier(this._repository, this.quizId, {QuizEntity? initialQuiz}) 
      : super(QuizDetailState(
          isLoading: initialQuiz == null, 
          quiz: initialQuiz,
        )) {
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
      state = state.copyWith(
        isLoading: false, 
        errorMessage: "No se ha podido encontrar este quiz, intente más tarde",
      );
    }
  }
  
  Future<void> refresh() async {
    await _loadQuiz();
  }
}



class QuizDetailFamilyParams {
  final String id;
  final QuizEntity? quiz;
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