import 'package:frontkahoot2526/features/library/domain/library_repository.dart';

class RemoveFavoriteQuizUseCase {
  final ILibraryRepository repository;

  RemoveFavoriteQuizUseCase(this.repository);
  Future<void> execute(String quizId){
    return repository.removeQuizFromFavorite(quizId);
  } 
}