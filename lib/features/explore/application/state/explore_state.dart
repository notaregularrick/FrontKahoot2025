import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/category_entity.dart';

class ExploreState {
  final bool isLoading;
  final List<QuizEntity> quizzes;
  final List<QuizEntity> featuredQuizzes;
  final List<CategoryEntity> availableCategories;
  final String? errorMessage;
  
  // Filtros
  final String searchQuery;
  final String? selectedCategory;
  
  // Paginación (para la lista principal)
  final int currentPage;
  final int totalPages;
  final bool hasMoreData;

  const ExploreState({
    this.isLoading = false,
    this.quizzes = const [],
    this.featuredQuizzes = const [],
    this.availableCategories = const [],
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
    List<QuizEntity>? featuredQuizzes,
    List<CategoryEntity>? availableCategories, 
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    int? currentPage,
    int? totalPages,
    bool? hasMoreData,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      quizzes: quizzes ?? this.quizzes,
      featuredQuizzes: featuredQuizzes ?? this.featuredQuizzes,
      availableCategories: availableCategories ?? this.availableCategories,
      errorMessage: errorMessage, 
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}