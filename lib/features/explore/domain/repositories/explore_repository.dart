import '../entities/paginated_quizzes_entity.dart';

abstract class ExploreRepository {
  
  // Endpoint: GET /explore
  // Este método recupera la lista paginada de quices con filtros opcionales.
  Future<PaginatedQuizzesEntity> getQuizzes({
    String? searchQuery,        // 'q' en el API: Texto a buscar
    List<String>? categories,   // 'categories' en el API: Filtro por tema
    int limit = 20,             // Cantidad por página
    int page = 1,               // Página actual
    String? orderBy,            // Campo de ordenamiento (ej: 'createdAt')
    String? order,              // Dirección ('asc' o 'desc')
  });

  // Espacio reservado para los futuros endpoints (H6.2 y H6.3)
  // Future<List<CategoryEntity>> getCategories();
  // Future<List<QuizEntity>> getFeaturedQuizzes();
}