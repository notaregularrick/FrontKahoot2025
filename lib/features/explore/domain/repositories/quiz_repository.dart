import '../entities/quiz_entity.dart';

abstract class QuizRepository {
  Future<QuizEntity> getQuizDetail(String id);
}