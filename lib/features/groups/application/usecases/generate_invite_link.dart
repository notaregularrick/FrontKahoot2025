import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class GenerateInviteLinkUseCase {
  final GroupsRepository repo;
  GenerateInviteLinkUseCase(this.repo);

  Future<String> call(String groupId, {required String expiresIn}) => repo.generateInviteLink(groupId, expiresIn: expiresIn);
}
