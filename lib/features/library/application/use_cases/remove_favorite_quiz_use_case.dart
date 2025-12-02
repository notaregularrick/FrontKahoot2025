import 'package:frontkahoot2526/features/library/domain/library_repository.dart';
import 'package:frontkahoot2526/features/library/infrastructure/fake_library_repository_impl.dart';

class RemoveFavoriteQuizUseCase {
  final ILibraryRepository repository;

  RemoveFavoriteQuizUseCase(this.repository);
  //falta obtener la url de la imagen y mostrarla
  Future<void> execute(String quizId){
    return repository.removeFavorite(quizId);
  } 
}


void main() async {
  final useCase = RemoveFavoriteQuizUseCase(FakeLibraryRepository());
  await useCase.execute('quiz-math-001');
}