import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';

abstract class ILibraryRepository {
  
  //H7.1 Quices creados y borradores
  Future<PaginatedResult<Quiz>> findMyCreations(LibraryFilterParams params);

  //H7.2 Quices favoritos
  Future<PaginatedResult<Quiz>> findFavorites(LibraryFilterParams params);

  //H7.3 Quices en progreso
  Future<PaginatedResult<Quiz>> findKahootsInProgress(LibraryFilterParams params);

  //H7.4 Quices completados
  Future<PaginatedResult<Quiz>> findCompletedKahoots(LibraryFilterParams params);
}