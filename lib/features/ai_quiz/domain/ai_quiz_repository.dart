import 'package:frontkahoot2526/core/domain/entities/quiz.dart';

abstract class IAIQuizRepository {
  /// Genera un quiz completo usando IA basado en un prompt
  /// Retorna un Quiz con preguntas, respuestas y metadata generados
  Future<Quiz> generateQuiz({
    required String prompt,
    required String title,
    required String description,
    required String category,
    int numberOfQuestions = 5,
  });
}


