import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';

class GetGroupsUseCase {
  final GroupsRepository repo;
  GetGroupsUseCase(this.repo);

  Future<List<GroupSummary>> call() => repo.fetchGroups();
}
