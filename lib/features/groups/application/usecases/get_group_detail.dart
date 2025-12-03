import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';

class GetGroupDetailUseCase {
  final GroupsRepository repo;
  GetGroupDetailUseCase(this.repo);

  Future<GroupDetail> call(String groupId) => repo.fetchGroupDetail(groupId);
}
