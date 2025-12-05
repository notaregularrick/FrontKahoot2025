import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class ChangeMemberRoleUseCase {
  final GroupsRepository repo;
  ChangeMemberRoleUseCase(this.repo);

  Future<void> call(String groupId, String memberId, String newRole) => repo.changeMemberRole(groupId, memberId, newRole);
}
