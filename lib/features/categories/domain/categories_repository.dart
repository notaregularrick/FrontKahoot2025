import 'package:frontkahoot2526/core/domain/entities/category.dart';

/// Repositorio abstracto para gestionar las categorías de quizzes
abstract class ICategoriesRepository {
  /// Obtiene la lista de categorías disponibles desde el backend
  /// Endpoint: GET /explore/categories
  /// Retorna lista de Category con el nombre de cada categoría
  Future<List<Category>> getCategories();
}

