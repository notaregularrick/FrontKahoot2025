import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/domain/library_quiz.dart';

abstract class ILibraryRepository {
  
  //H7.1 Quices creados y borradores
  Future<PaginatedResult<LibraryQuiz>> findMyCreations(LibraryFilterParams params);

  //H7.2 Quices favoritos
  Future<PaginatedResult<LibraryQuiz>> findFavorites(LibraryFilterParams params);

  //H7.3 Quices en progreso
  Future<PaginatedResult<LibraryQuiz>> findQuizzesInProgress(LibraryFilterParams params);

  //H7.4 Quices completados
  Future<PaginatedResult<LibraryQuiz>> findCompletedQuizzes(LibraryFilterParams params);
}