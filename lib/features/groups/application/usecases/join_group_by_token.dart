import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';

class JoinGroupByTokenUseCase {
  final GroupsRepository repo;
  JoinGroupByTokenUseCase(this.repo);

  Future<GroupSummary> call(String token, {required String name, String? email}) => repo.joinGroupWithToken(token, name: name, email: email);
}
