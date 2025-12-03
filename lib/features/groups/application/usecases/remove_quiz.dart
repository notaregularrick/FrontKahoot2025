import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class RemoveQuizUseCase {
  final GroupsRepository repo;
  RemoveQuizUseCase(this.repo);

  Future<void> call(String groupId, String quizId) => repo.removeQuiz(groupId, quizId);
}
