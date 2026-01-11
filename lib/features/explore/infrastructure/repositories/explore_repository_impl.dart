import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/explore_repository.dart';
import '../../domain/entities/paginated_quizzes_entity.dart';
import '../datasource/explore_datasource.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreDatasource datasource;

  ExploreRepositoryImpl(this.datasource);

  @override
  Future<PaginatedQuizzesEntity> getQuizzes({
    String? searchQuery,
    List<String>? categories,
    int limit = 20,
    int page = 1,
    String? orderBy,
    String? order,
  }) async {
    try {
      final model = await datasource.getQuizzes(
        searchQuery: searchQuery,
        categories: categories,
        limit: limit,
        page: page,
        orderBy: orderBy,
        order: order,
      );

      return model;
    } catch (e) {
      throw Exception('Error en ExploreRepository: $e');
    }
  }

  @override
  Future<PaginatedQuizzesEntity> getFeaturedQuizzes({int limit = 10}) async {
    try {
      return await datasource.getFeaturedQuizzes(limit: limit);
    } catch (e) {
      throw Exception('Error obteniendo destacados: $e');
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      return await datasource.getCategories();
    } catch (e) {
      throw Exception('Error obteniendo categorías: $e');
    }
  }
}