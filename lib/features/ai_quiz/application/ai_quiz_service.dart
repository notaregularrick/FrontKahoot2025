import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/ai_quiz/domain/ai_quiz_repository.dart';

class AIQuizService {
  final IAIQuizRepository repository;

  AIQuizService(this.repository);

  Future<Quiz> generateQuiz({
    required String prompt,
    required String title,
    required String description,
    required String category,
    int numberOfQuestions = 5,
  }) {
    print('Generando quiz: "$title"');
    return repository.generateQuiz(
      prompt: prompt,
      title: title,
      description: description,
      category: category,
      numberOfQuestions: numberOfQuestions,
    );
  }
}


