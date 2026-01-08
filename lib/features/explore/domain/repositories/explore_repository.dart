import '../entities/category_entity.dart';
import '../entities/paginated_quizzes_entity.dart';

abstract class ExploreRepository {
  
  // H6.1: Búsqueda y Filtrado
  Future<PaginatedQuizzesEntity> getQuizzes({
    String? searchQuery,        // 'q' en el API: Texto a buscar
    List<String>? categories,   // 'categories' en el API: Filtro por tema
    int limit = 20,             // Cantidad por página
    int page = 1,               // Página actual
    String? orderBy,            // Campo de ordenamiento (ej: 'createdAt')
    String? order,              // Dirección ('asc' o 'desc')
  });

  // H6.2: Quices Destacados
  Future<PaginatedQuizzesEntity> getFeaturedQuizzes({
    int limit = 10,
  });
  
  // H6.3: Listado de Categorías
  Future<List<CategoryEntity>> getCategories();
}