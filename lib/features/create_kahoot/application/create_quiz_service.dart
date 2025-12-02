import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/create_kahoot/domain/create_quiz_repository.dart';

class CreateQuizService {
  final ICreateQuizRepository repository;

  CreateQuizService(this.repository);

  /// Crea un nuevo quiz delegando al repositorio
  Future<Quiz> createQuiz(Quiz quiz) {
    return repository.createQuiz(quiz);
  }
}

