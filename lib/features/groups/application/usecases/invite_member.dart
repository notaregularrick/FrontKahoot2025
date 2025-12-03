import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class InviteMemberUseCase {
  final GroupsRepository repo;
  InviteMemberUseCase(this.repo);

  Future<void> call(String groupId, String email, String role) => repo.inviteMember(groupId, email, role);
}
