import 'dart:async';
import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';

class MockGroupsRepository implements GroupsRepository {
  final List<GroupSummary> _groups = List.generate(6, (i) => GroupSummary(
    id: 'g$i',
    name: 'Grupo ${i+1}',
    description: 'Descripción del grupo ${i+1}',
    createdAt: DateTime.now().subtract(Duration(days: i * 7)),
    memberCount: 5 + i,
    role: i % 3 == 0 ? 'admin' : (i % 3 == 1 ? 'teacher' : 'student'),
    assignedQuizzesCount: i * 2,
  ));

  final Map<String, List<Member>> _members = {};
  final Map<String, List<AssignedQuiz>> _assigned = {};
  final Map<String, String> _inviteTokens = {}; // token -> groupId

  @override
  Future<GroupSummary> createGroup({required String name, String? description}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final group = GroupSummary(id: id, name: name, description: description, createdAt: DateTime.now(), memberCount: 1, role: 'admin', assignedQuizzesCount: 0);
    _groups.insert(0, group);
    return group;
  }

  @override
  Future<List<GroupSummary>> fetchGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<GroupSummary>.from(_groups);
  }

  @override
  Future<GroupDetail> fetchGroupDetail(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final found = _groups.firstWhere((g) => g.id == groupId, orElse: () => GroupSummary(id: groupId, name: 'Grupo $groupId', description: null, createdAt: DateTime.now(), memberCount: 0, role: 'student', assignedQuizzesCount: 0));
    return GroupDetail(
      id: found.id,
      name: found.name,
      description: found.description ?? 'Descripción extendida del grupo ${found.id}',
      createdAt: found.createdAt,
      creatorId: 'u1',
      totalMembers: found.memberCount,
      totalAssignedQuizzes: found.assignedQuizzesCount,
      myRole: found.role,
    );
  }

  @override
  Future<List<Member>> fetchMembers(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _members.putIfAbsent(groupId, () {
      return List.generate(6, (i) => Member(id: '${groupId}_u$i', name: 'Usuario $i', email: 'u$i@example.com', role: i==0? 'admin' : (i%3==0?'teacher':'student'), joinedAt: DateTime.now().subtract(Duration(days: i*2))));
    });
    return List<Member>.from(_members[groupId]!);
  }

  @override
  // fetchQuizzes is implemented later to return persisted assigned quizzes

  @override
  Future<List<RankingEntry>> fetchRanking(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(5, (i) => RankingEntry(userId: 'u$i', userName: 'Usuario $i', completedCount: 3-i%3, totalScore: 100 - i*10, position: i+1));
  }

  @override
  Future<void> inviteMember(String groupId, String email, String role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final memberId = '${groupId}_u${DateTime.now().millisecondsSinceEpoch}';
    final member = Member(id: memberId, name: email.split('@').first, email: email, role: role, joinedAt: DateTime.now());
    _members.putIfAbsent(groupId, () => []).insert(0, member);
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx >= 0) _groups[idx] = GroupSummary(id: _groups[idx].id, name: _groups[idx].name, description: _groups[idx].description, createdAt: _groups[idx].createdAt, memberCount: _groups[idx].memberCount + 1, role: _groups[idx].role, assignedQuizzesCount: _groups[idx].assignedQuizzesCount);
    return;
  }

  @override
  Future<void> removeMember(String groupId, String memberId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _members[groupId];
    if (list != null) {
      list.removeWhere((m) => m.id == memberId);
      final idx = _groups.indexWhere((g) => g.id == groupId);
      if (idx >= 0) {
        final g = _groups[idx];
        _groups[idx] = GroupSummary(id: g.id, name: g.name, description: g.description, createdAt: g.createdAt, memberCount: (g.memberCount - 1).clamp(0, 99999), role: g.role, assignedQuizzesCount: g.assignedQuizzesCount);
      }
    }
    return;
  }

  @override
  Future<GroupDetail> updateGroup(String groupId, {String? name, String? description}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx >= 0) {
      final old = _groups[idx];
      final updated = GroupSummary(id: old.id, name: name ?? old.name, description: description ?? old.description, createdAt: old.createdAt, memberCount: old.memberCount, role: old.role, assignedQuizzesCount: old.assignedQuizzesCount);
      _groups[idx] = updated;
      return GroupDetail(id: updated.id, name: updated.name, description: updated.description, createdAt: updated.createdAt, creatorId: 'u1', totalMembers: updated.memberCount, totalAssignedQuizzes: updated.assignedQuizzesCount, myRole: updated.role);
    }
    throw Exception('Group not found');
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _groups.removeWhere((g) => g.id == groupId);
    _members.remove(groupId);
    return;
  }

  @override
  Future<String> generateInviteLink(String groupId, {String role = 'student'}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final token = 'inv_${DateTime.now().millisecondsSinceEpoch}';
    _inviteTokens[token] = groupId;
    // return a fake deep link (your production app should provide a real URL)
    return 'frontkahoot://groups/join/$token';
  }

  @override
  Future<GroupSummary> joinGroupWithToken(String token, {required String name, String? email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final groupId = _inviteTokens[token];
    if (groupId == null) throw Exception('Token inválido o expirado');
    // create member
    final memberId = '${groupId}_u${DateTime.now().millisecondsSinceEpoch}';
    final member = Member(id: memberId, name: name, email: email, role: 'student', joinedAt: DateTime.now());
    _members.putIfAbsent(groupId, () => []).insert(0, member);
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx >= 0) {
      final g = _groups[idx];
      _groups[idx] = GroupSummary(id: g.id, name: g.name, description: g.description, createdAt: g.createdAt, memberCount: g.memberCount + 1, role: g.role, assignedQuizzesCount: g.assignedQuizzesCount);
      return _groups[idx];
    }
    throw Exception('Grupo no encontrado');
  }

  @override
  Future<void> changeMemberRole(String groupId, String memberId, String newRole) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _members[groupId];
    if (list != null) {
      final idx = list.indexWhere((m) => m.id == memberId);
      if (idx >= 0) {
        final old = list[idx];
        list[idx] = Member(id: old.id, name: old.name, email: old.email, role: newRole, joinedAt: old.joinedAt);
      }
    }
    return;
  }

  @override
  Future<void> assignQuiz(String groupId, String quizId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _assigned.putIfAbsent(groupId, () => []);
    final assigned = AssignedQuiz(id: quizId, title: 'Quiz $quizId', description: 'Asignado $quizId', author: 'Autor', status: 'published', assignedAt: DateTime.now());
    list.insert(0, assigned);
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx >= 0) {
      final g = _groups[idx];
      _groups[idx] = GroupSummary(id: g.id, name: g.name, description: g.description, createdAt: g.createdAt, memberCount: g.memberCount, role: g.role, assignedQuizzesCount: g.assignedQuizzesCount + 1);
    }
    return;
  }

  @override
  Future<void> removeQuiz(String groupId, String quizId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _assigned[groupId];
    if (list != null) {
      list.removeWhere((q) => q.id == quizId);
      final idx = _groups.indexWhere((g) => g.id == groupId);
      if (idx >= 0) {
        final g = _groups[idx];
        _groups[idx] = GroupSummary(id: g.id, name: g.name, description: g.description, createdAt: g.createdAt, memberCount: g.memberCount, role: g.role, assignedQuizzesCount: (g.assignedQuizzesCount - 1).clamp(0, 99999));
      }
    }
    return;
  }
  
  @override
  Future<List<AssignedQuiz>> fetchQuizzes(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<AssignedQuiz>.from(_assigned.putIfAbsent(groupId, () => []));
  }
}
