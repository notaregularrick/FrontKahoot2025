import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';

class UpdateGroupUseCase {
  final GroupsRepository repo;
  UpdateGroupUseCase(this.repo);

  Future<GroupDetail> call(String groupId, {String? name, String? description}) => repo.updateGroup(groupId, name: name, description: description);
}
