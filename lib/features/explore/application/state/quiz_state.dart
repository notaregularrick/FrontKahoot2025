import '../../domain/entities/quiz_entity.dart';


class QuizDetailState {
  final bool isLoading;
  final QuizEntity? quiz;
  final String? errorMessage;

  const QuizDetailState({
    this.isLoading = false,
    this.quiz,
    this.errorMessage,
  });

  QuizDetailState copyWith({
    bool? isLoading,
    QuizEntity? quiz,
    String? errorMessage,
  }) {
    return QuizDetailState(
      isLoading: isLoading ?? this.isLoading,
      quiz: quiz ?? this.quiz,
      errorMessage: errorMessage,
    );
  }
}