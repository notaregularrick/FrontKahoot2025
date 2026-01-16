import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasource/quiz_datasource.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizDatasource datasource;
  QuizRepositoryImpl(this.datasource);

  @override
  Future<QuizEntity> getQuizDetail(String id) async {
    final model = await datasource.getQuizDetail(id);
    return model; 
  }
}