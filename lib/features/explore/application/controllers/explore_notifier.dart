import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/explore_repository.dart';
import '../state/explore_state.dart';

class ExploreNotifier extends StateNotifier<ExploreState> {
  final ExploreRepository repository;
  
  // Bandera local para evitar múltiples llamadas de paginación simultáneas
  bool _isFetchingMore = false; 

  ExploreNotifier(this.repository) : super(ExploreState.initial()) {
  loadInitialData();
}

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.wait([
      loadFeaturedQuizzes(),
      loadCategories(),
      loadQuizzes(isLoadMore: false, setGlobalLoading: false),
    ]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> loadCategories() async {
    try {
      final categories = await repository.getCategories();
      state = state.copyWith(availableCategories: categories);
    } catch (e) {
      print("Error cargando categorías: $e");
    }
  }

  Future<void> loadFeaturedQuizzes() async {
    try {
      final result = await repository.getFeaturedQuizzes(limit: 5);
      state = state.copyWith(featuredQuizzes: result.quizzes);
    } catch (e) {
      print("Error cargando destacados: $e");
    }
  }

  Future<void> loadQuizzes({bool isLoadMore = false, bool setGlobalLoading = true}) async {
    // 1. Validaciones de bloqueo
    if (setGlobalLoading && state.isLoading) return; // Ya está cargando inicio
    if (isLoadMore && !state.hasMoreData) return;    // No hay más datos
    if (isLoadMore && _isFetchingMore) return;       // CORRECCIÓN: Ya está paginando

    try {
      if (setGlobalLoading && !isLoadMore) {
        state = state.copyWith(isLoading: true, errorMessage: null);
      }
      
      if (isLoadMore) {
        _isFetchingMore = true; // Bloqueamos nuevas peticiones
      }

      final pageToLoad = isLoadMore ? state.currentPage + 1 : 1;

      final result = await repository.getQuizzes(
        searchQuery: state.searchQuery,
        categories: state.selectedCategory != null ? [state.selectedCategory!] : null,
        page: pageToLoad,
        limit: 20,
      );

      final newQuizzes = result.quizzes;
      final pagination = result.pagination;

      state = state.copyWith(
        isLoading: setGlobalLoading ? false : state.isLoading,
        quizzes: isLoadMore ? [...state.quizzes, ...newQuizzes] : newQuizzes,
        currentPage: pagination.page,
        totalPages: pagination.totalPages,
        hasMoreData: pagination.page < pagination.totalPages,
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    } finally {
      _isFetchingMore = false; // Desbloqueamos siempre al final
    }
  }

  void onSearchChanged(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    loadQuizzes(isLoadMore: false);
  }

  void onCategorySelected(String? categoryId) {
    final newCategory = state.selectedCategory == categoryId ? null : categoryId;
    if (state.selectedCategory == newCategory) return;

    state = state.copyWith(
      selectedCategory: newCategory,
      clearSelectedCategory: newCategory == null,
    );
    loadQuizzes(isLoadMore: false);
  }
  
  Future<void> refresh() async {
    await loadInitialData();
  }
}