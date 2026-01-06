import '../../domain/entities/quiz_entity.dart';

class ExploreState {
  final bool isLoading;
  final List<QuizEntity> quizzes;
  final String? errorMessage;
  
  // Filtros activos
  final String searchQuery;
  final String? selectedCategory; // null significa "Todas"
  
  // Paginación
  final int currentPage;
  final int totalPages;
  final bool hasMoreData;

  const ExploreState({
    this.isLoading = false,
    this.quizzes = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMoreData = true,
  });

  factory ExploreState.initial() => const ExploreState();

  ExploreState copyWith({
    bool? isLoading,
    List<QuizEntity>? quizzes,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    int? currentPage,
    int? totalPages,
    bool? hasMoreData,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      quizzes: quizzes ?? this.quizzes,
      // Si errorMessage es null en el copyWith, mantenemos el actual.
      // Para limpiar el error explícitamente, podrías pasar una cadena vacía o manejar lógica extra,
      // pero aquí asumiremos que cada nueva carga limpia el error en el Notifier.
      errorMessage: errorMessage, 
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}