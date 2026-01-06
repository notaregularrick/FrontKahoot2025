import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/explore_repository.dart';
import '../state/explore_state.dart';

class ExploreNotifier extends StateNotifier<ExploreState> {
  final ExploreRepository repository;

  ExploreNotifier(this.repository) : super(ExploreState.initial());

  // Cargar quices (inicial o paginación)
  Future<void> loadQuizzes({bool isLoadMore = false}) async {
    // Evitar cargas duplicadas si ya está cargando
    if (state.isLoading) return;
    
    // Si es "Cargar más" y ya no hay datos, salimos
    if (isLoadMore && !state.hasMoreData) return;

    try {
      // Si NO es loadMore (es una búsqueda nueva o refresh), ponemos loading y limpiamos error
      if (!isLoadMore) {
        state = state.copyWith(isLoading: true, errorMessage: null);
      } 
      // Si ES loadMore, no ponemos isLoading global para no bloquear toda la UI,
      // pero podrías manejar un booleano 'isLoadingMore' separado si quisieras mostrar un spinner abajo.

      final pageToLoad = isLoadMore ? state.currentPage + 1 : 1;

      final result = await repository.getQuizzes(
        searchQuery: state.searchQuery,
        categories: state.selectedCategory != null ? [state.selectedCategory!] : null,
        page: pageToLoad,
        limit: 20, // Puedes hacerlo configurable
      );

      final newQuizzes = result.quizzes;
      final pagination = result.pagination;

      state = state.copyWith(
        isLoading: false,
        // Si es loadMore, concatenamos. Si no, reemplazamos.
        quizzes: isLoadMore ? [...state.quizzes, ...newQuizzes] : newQuizzes,
        currentPage: pagination.page,
        totalPages: pagination.totalPages,
        // Calculamos si hay más páginas
        hasMoreData: pagination.page < pagination.totalPages,
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Cambio en la barra de búsqueda
  void onSearchChanged(String query) {
    if (state.searchQuery == query) return;
    
    // Actualizamos el query y reseteamos la lista
    state = state.copyWith(searchQuery: query);
    loadQuizzes(isLoadMore: false);
  }

  // Cambio de categoría
  void onCategorySelected(String? categoryId) {
    if (state.selectedCategory == categoryId) return;

    state = state.copyWith(selectedCategory: categoryId);
    loadQuizzes(isLoadMore: false);
  }
  
  // Pull to refresh
  Future<void> refresh() async {
    await loadQuizzes(isLoadMore: false);
  }
}