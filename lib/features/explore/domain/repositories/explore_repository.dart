import '../entities/category_entity.dart';
import '../entities/paginated_quizzes_entity.dart';

abstract class ExploreRepository {
  
  // H6.1: Búsqueda y Filtrado
  Future<PaginatedQuizzesEntity> getQuizzes({
    String? searchQuery,        
    List<String>? categories,   
    int limit = 20,             
    int page = 1,               
    String? orderBy,            
    String? order,              
  });

  // H6.2: Quices Destacados
  Future<PaginatedQuizzesEntity> getFeaturedQuizzes({
    int limit = 10,
  });
  
  // H6.3: Listado de Categorías
  Future<List<CategoryEntity>> getCategories();
}