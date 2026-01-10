import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class AssignQuizUseCase {
  final GroupsRepository repo;
  AssignQuizUseCase(this.repo);

  Future<void> call(String groupId, String quizId, {String? availableFrom, String? availableUntil}) {
    return repo.assignQuiz(groupId, quizId, availableFrom: availableFrom, availableUntil: availableUntil);
  }
}
