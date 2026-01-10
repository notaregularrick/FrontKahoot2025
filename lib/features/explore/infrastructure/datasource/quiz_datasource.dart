import '../models/quiz_model.dart';

abstract class QuizDatasource {
  Future<QuizModel> getQuizDetail(String id);
}