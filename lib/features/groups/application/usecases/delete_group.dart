import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class DeleteGroupUseCase {
  final GroupsRepository repo;
  DeleteGroupUseCase(this.repo);

  Future<void> call(String groupId) => repo.deleteGroup(groupId);
}
