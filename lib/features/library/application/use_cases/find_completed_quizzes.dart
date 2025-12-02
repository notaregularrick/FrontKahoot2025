

import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/domain/library_quiz.dart';
import 'package:frontkahoot2526/features/library/domain/library_repository.dart';

class FindCompletedQuizzesUseCase {
  final ILibraryRepository repository;
  final LibraryFilterParams params;

  FindCompletedQuizzesUseCase(this.repository, this.params);
  //falta obtener la url de la imagen y mostrarla
  Future<PaginatedResult<LibraryQuiz>> execute(){
    return repository.findCompletedQuizzes(params);
  } 
}
