import '../models/paginated_quizzes_model.dart';

abstract class ExploreDatasource {
  Future<PaginatedQuizzesModel> getQuizzes({
    String? searchQuery,
    List<String>? categories,
    int limit = 20,
    int page = 1,
    String? orderBy,
    String? order,
  });
}