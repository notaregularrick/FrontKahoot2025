

import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/domain/library_quiz.dart';
import 'package:frontkahoot2526/features/library/domain/library_repository.dart';
import 'package:frontkahoot2526/features/library/infrastructure/fake_library_repository_impl.dart';

class FindFavoritesUseCase {
  final ILibraryRepository repository;
  final LibraryFilterParams params;

  FindFavoritesUseCase(this.repository, this.params);
  //falta obtener la url de la imagen y mostrarla
  Future<PaginatedResult<LibraryQuiz>> execute(){
    return repository.findFavorites(params);
  } 
}


void main() async {
  final useCase = FindFavoritesUseCase(FakeLibraryRepository(),LibraryFilterParams());
  final result = await useCase.execute();
  print('Total Count: ${result.totalCount}');
  print('Total Pages: ${result.totalPages}');
  print('Current Page: ${result.currentPage}');
  print('Limit: ${result.limit}');
  print('Items:');
  for (var quiz in result.items) {
    print('- ${quiz.title}');
  }
}