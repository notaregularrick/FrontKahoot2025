import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/create_kahoot/domain/create_quiz_repository.dart';

class CreateQuizService {
  final ICreateQuizRepository repository;

  CreateQuizService(this.repository);

  /// Crea un nuevo quiz delegando al repositorio
  Future<Quiz> createQuiz(Quiz quiz) {
    return repository.createQuiz(quiz);
  }

  /// Obtiene un quiz por ID
  Future<Quiz> getQuiz(String quizId) {
    return repository.getQuiz(quizId);
  }

  /// Actualiza un quiz existente
  Future<Quiz> updateQuiz(String quizId, Quiz quiz) {
    return repository.updateQuiz(quizId, quiz);
  }
}

