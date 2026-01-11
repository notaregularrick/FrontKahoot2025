import '../models/category_model.dart';
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

  Future<PaginatedQuizzesModel> getFeaturedQuizzes({
    int limit = 10,
  });

  Future<List<CategoryModel>> getCategories();
}