import 'package:frontkahoot2526/features/library/domain/library_repository.dart';

class AddQuizToFavoriteUseCase {
  final ILibraryRepository repository;

  AddQuizToFavoriteUseCase(this.repository);
  Future<void> execute(String quizId){
    return repository.addQuizToFavorite(quizId);
  } 
}