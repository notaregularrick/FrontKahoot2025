import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/create_kahoot/domain/create_quiz_repository.dart';

class FakeCreateQuizRepository implements ICreateQuizRepository {
  @override
  Future<Quiz> createQuiz(Quiz quiz) async {
    try {

      await Future.delayed(const Duration(milliseconds: 500));


      final String generatedId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';

      final createdQuiz = Quiz(
        id: generatedId,
        title: quiz.title,
        description: quiz.description,
        coverImageId: quiz.coverImageId,
        visibility: quiz.visibility,
        status: quiz.status,
        category: quiz.category,
        themeId: quiz.themeId,
        authorId: quiz.authorId,
        authorName: quiz.authorName,
        questions: quiz.questions,
        createdAt: DateTime.now(),
        playCount: quiz.playCount,
      );

      // Reemplazar por llamada a la API
      // ejemplo
      // final dio = Dio();
      // final response = await dio.post(
      //   'https://api.example.com/quizzes',
      //   data: quizToJson(quiz),
      // );
      // return quizFromJson(response.data);

      return createdQuiz;
    } catch (e) {
      throw AppException(
        message: "Error al crear el quiz",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }
}

