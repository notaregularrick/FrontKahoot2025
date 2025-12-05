import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class GenerateInviteLinkUseCase {
  final GroupsRepository repo;
  GenerateInviteLinkUseCase(this.repo);

  Future<String> call(String groupId, {String role = 'student'}) => repo.generateInviteLink(groupId, role: role);
}
