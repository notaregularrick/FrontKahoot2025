import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';

class CreateGroupUseCase {
  final GroupsRepository repo;
  CreateGroupUseCase(this.repo);

  Future<GroupSummary> call({required String name, String? description}) => repo.createGroup(name: name, description: description);
}
