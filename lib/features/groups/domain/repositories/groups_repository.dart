import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';

abstract class GroupsRepository {
  Future<List<GroupSummary>> fetchGroups();
  Future<GroupDetail> fetchGroupDetail(String groupId);
  Future<List<Member>> fetchMembers(String groupId);
  Future<List<AssignedQuiz>> fetchQuizzes(String groupId);
  Future<List<RankingEntry>> fetchRanking(String groupId);

  Future<GroupSummary> createGroup({required String name, String? description});
  Future<void> inviteMember(String groupId, String email, String role);
  Future<void> removeMember(String groupId, String memberId);
  Future<void> assignQuiz(String groupId, String quizId);
  Future<void> removeQuiz(String groupId, String quizId);
  Future<GroupDetail> updateGroup(String groupId, {String? name, String? description});
  Future<void> deleteGroup(String groupId);
  Future<void> changeMemberRole(String groupId, String memberId, String newRole);
  // Invite link flow
  Future<String> generateInviteLink(String groupId, {String role});
  Future<GroupSummary> joinGroupWithToken(String token, {required String name, String? email});
}
