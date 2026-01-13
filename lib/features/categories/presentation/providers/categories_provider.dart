import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/domain/entities/category.dart';
import 'package:frontkahoot2526/core/network/dio_provider.dart';
import 'package:frontkahoot2526/features/categories/domain/categories_repository.dart';
import 'package:frontkahoot2526/features/categories/infrastructure/categories_repository_impl.dart';

/// Provider para el repositorio de categorías
final categoriesRepositoryProvider = Provider<ICategoriesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CategoriesRepositoryImpl(dio: dio);
});

/// Provider que obtiene las categorías del backend
/// Las categorías se cachean automáticamente con el ciclo de vida del provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoriesRepositoryProvider);
  return repository.getCategories();
});

/// Provider que retorna solo los nombres de las categorías como lista de strings
/// Útil para los dropdowns existentes que esperan List<String>
final categoryNamesProvider = FutureProvider<List<String>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.map((c) => c.name).toList();
});

