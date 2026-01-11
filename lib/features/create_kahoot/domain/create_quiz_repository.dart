import 'package:frontkahoot2526/core/domain/entities/quiz.dart';

abstract class ICreateQuizRepository {
  /// Crea un nuevo quiz
  /// Retorna el quiz creado con ID generado y timestamp de creación
  Future<Quiz> createQuiz(Quiz quiz);

  /// Obtiene un quiz existente por su ID
  Future<Quiz> getQuiz(String quizId);

  /// Actualiza un quiz existente
  Future<Quiz> updateQuiz(String quizId, Quiz quiz);
}

