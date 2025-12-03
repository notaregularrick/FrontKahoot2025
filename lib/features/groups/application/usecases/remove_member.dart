import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class RemoveMemberUseCase {
  final GroupsRepository repo;
  RemoveMemberUseCase(this.repo);

  Future<void> call(String groupId, String memberId) => repo.removeMember(groupId, memberId);
}
