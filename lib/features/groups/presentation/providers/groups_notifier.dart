import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';
import 'package:frontkahoot2526/features/groups/infrastructure/repositories/groups_repository_mock.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/get_groups.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/create_group.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/get_group_detail.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/update_group.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/delete_group.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/invite_member.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/remove_member.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/change_member_role.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/assign_quiz.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/remove_quiz.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/generate_invite_link.dart';
import 'package:frontkahoot2526/features/groups/application/usecases/join_group_by_token.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) => MockGroupsRepository());

final groupsListProvider = StateNotifierProvider<GroupsListNotifier, AsyncValue<List<GroupSummary>>>((ref) {
  final repo = ref.watch(groupsRepositoryProvider);
  return GroupsListNotifier(ref, repo);
});

class GroupsListNotifier extends StateNotifier<AsyncValue<List<GroupSummary>>> {
  final Ref ref;
  final GroupsRepository repo;
  GroupsListNotifier(this.ref, this.repo) : super(const AsyncValue.loading()) {
    _getGroups = GetGroupsUseCase(repo);
    _createGroup = CreateGroupUseCase(repo);
    load();
  }

  late final GetGroupsUseCase _getGroups;
  late final CreateGroupUseCase _createGroup;

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      final items = await _getGroups.call();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<GroupSummary> createGroup(String name, String? description) async {
    final created = await _createGroup.call(name: name, description: description);
    // refresh this list
    await load();
    return created;
  }
}

final groupDetailProvider = StateNotifierProvider.family<GroupDetailNotifier, AsyncValue<GroupDetail>, String>((ref, groupId) {
  final repo = ref.watch(groupsRepositoryProvider);
  return GroupDetailNotifier(ref, repo, groupId);
});

class GroupDetailNotifier extends StateNotifier<AsyncValue<GroupDetail>> {
  final Ref ref;
  final GroupsRepository repo;
  final String groupId;
  GroupDetailNotifier(this.ref, this.repo, this.groupId) : super(const AsyncValue.loading()) {
    _getDetail = GetGroupDetailUseCase(repo);
    _update = UpdateGroupUseCase(repo);
    _delete = DeleteGroupUseCase(repo);
    _invite = InviteMemberUseCase(repo);
    _remove = RemoveMemberUseCase(repo);
    _changeRole = ChangeMemberRoleUseCase(repo);
    _assignQuiz = AssignQuizUseCase(repo);
    _removeQuiz = RemoveQuizUseCase(repo);
    _generateInvite = GenerateInviteLinkUseCase(repo);
    _joinByToken = JoinGroupByTokenUseCase(repo);
    load();
  }

  late final GetGroupDetailUseCase _getDetail;
  late final UpdateGroupUseCase _update;
  late final DeleteGroupUseCase _delete;
  late final InviteMemberUseCase _invite;
  late final RemoveMemberUseCase _remove;
  late final ChangeMemberRoleUseCase _changeRole;
  late final AssignQuizUseCase _assignQuiz;
  late final RemoveQuizUseCase _removeQuiz;
  late final GenerateInviteLinkUseCase _generateInvite;
  late final JoinGroupByTokenUseCase _joinByToken;

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      final detail = await _getDetail.call(groupId);
      state = AsyncValue.data(detail);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<Member>> loadMembers() => repo.fetchMembers(groupId);
  Future<List<AssignedQuiz>> loadQuizzes() => repo.fetchQuizzes(groupId);
  Future<List<RankingEntry>> loadRanking() => repo.fetchRanking(groupId);
  Future<String> generateInviteLink({String role = 'student'}) => _generateInvite.call(groupId, role: role);
  Future<GroupSummary> joinGroupWithToken(String token, {required String name, String? email}) => _joinByToken.call(token, name: name, email: email);
  Future<void> inviteMember(String email, String role) async {
    await _invite.call(groupId, email, role);
    // refresh detail and groups list (member counts may have changed)
    await load();
    await ref.read(groupsListProvider.notifier).load();
  }

  Future<void> removeMember(String memberId) async {
    await _remove.call(groupId, memberId);
    await load();
    await ref.read(groupsListProvider.notifier).load();
  }

  Future<GroupDetail> updateGroup({String? name, String? description}) async {
    final updated = await _update.call(groupId, name: name, description: description);
    await load();
    await ref.read(groupsListProvider.notifier).load();
    return updated;
  }

  Future<void> deleteGroup() async {
    await _delete.call(groupId);
    // refresh groups list; navigation should be handled by the UI caller
    await ref.read(groupsListProvider.notifier).load();
  }

  Future<void> changeMemberRole(String memberId, String newRole) async {
    await _changeRole.call(groupId, memberId, newRole);
    await load();
  }

  Future<void> assignQuiz(String quizId) async {
    await _assignQuiz.call(groupId, quizId);
    await load();
  }

  Future<void> removeQuiz(String quizId) async {
    await _removeQuiz.call(groupId, quizId);
    await load();
  }
}
