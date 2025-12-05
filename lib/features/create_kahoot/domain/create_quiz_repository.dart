import 'package:frontkahoot2526/core/domain/entities/quiz.dart';

abstract class ICreateQuizRepository {
  /// Crea un nuevo quiz
  /// Retorna el quiz creado con ID generado y timestamp de creación
  Future<Quiz> createQuiz(Quiz quiz);
}

