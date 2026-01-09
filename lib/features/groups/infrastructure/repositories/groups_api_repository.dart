import 'package:dio/dio.dart';
import 'package:frontkahoot2526/features/groups/domain/entities/group_models.dart';
import 'package:frontkahoot2526/features/groups/domain/repositories/groups_repository.dart';

class GroupsApiRepository implements GroupsRepository {
  final Dio _dio;

  GroupsApiRepository(this._dio);

  @override
  Future<List<GroupSummary>> fetchGroups() async {
    try {
      // Match backend behavior: simple GET /api/groups with Bearer
      final res = await _dio.get('/groups');
      // ignore: avoid_print
      print('[groups] status=${res.statusCode} type=${res.data.runtimeType}');
      final data = _unwrapList(res.data);
      return data.map(_mapGroupSummary).toList();
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[groups][error] status=${e.response?.statusCode} body=${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<GroupDetail> fetchGroupDetail(String groupId) async {
    final res = await _dio.get('/groups/$groupId');
    final map = _unwrapMap(res.data);
    return _mapGroupDetail(map);
  }

  @override
  Future<List<Member>> fetchMembers(String groupId) async {
    final res = await _dio.get('/groups/$groupId/members');
    final data = _unwrapList(res.data);
    return data.map(_mapMember).toList();
  }

  @override
  Future<List<AssignedQuiz>> fetchQuizzes(String groupId) async {
    final res = await _dio.get('/groups/$groupId/quizzes');
    final data = _unwrapList(res.data);
    return data.map(_mapAssignedQuiz).toList();
  }

  @override
  Future<List<RankingEntry>> fetchRanking(String groupId) async {
    final res = await _dio.get('/groups/$groupId/ranking');
    final data = _unwrapList(res.data);
    return data.map(_mapRankingEntry).toList();
  }

  @override
  Future<GroupSummary> createGroup({required String name, String? description}) async {
    final payload = <String, dynamic>{'name': name};
    if (description != null && description.isNotEmpty) payload['description'] = description;
    final res = await _dio.post('/groups', data: payload);
    final map = _unwrapMap(res.data);
    return _mapGroupSummary(map);
  }

  @override
  Future<void> inviteMember(String groupId, String email, String role) async {
    await _dio.post('/groups/$groupId/members', data: {
      'email': email,
      'role': role,
    });
  }

  @override
  Future<void> removeMember(String groupId, String memberId) async {
    await _dio.delete('/groups/$groupId/members/$memberId');
  }

  @override
  Future<void> assignQuiz(String groupId, String quizId) async {
    // Shape not documented; sending single quizId as per domain.
    await _dio.post('/groups/$groupId/quizzes', data: {
      'quizId': quizId,
    });
  }

  @override
  Future<void> removeQuiz(String groupId, String quizId) async {
    // Not documented in API spec; keep unimplemented to avoid fake data.
    throw UnimplementedError('Remove quiz is not supported by the documented API');
  }

  @override
  Future<GroupDetail> updateGroup(String groupId, {String? name, String? description}) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (description != null) payload['description'] = description;
    final res = await _dio.patch('/groups/$groupId', data: payload);
    final map = _unwrapMap(res.data);
    return _mapGroupDetail(map);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _dio.delete('/groups/$groupId');
  }

  @override
  Future<void> changeMemberRole(String groupId, String memberId, String newRole) async {
    await _dio.patch('/groups/$groupId/members/$memberId', data: {
      'role': newRole,
    });
  }

  @override
  Future<String> generateInviteLink(String groupId, {String role = 'student'}) {
    // Not documented in API spec; keep unimplemented to avoid fake data.
    throw UnimplementedError('Invite link generation is not supported by the documented API');
  }

  @override
  Future<GroupSummary> joinGroupWithToken(String token, {required String name, String? email}) {
    // Not documented in API spec; keep unimplemented to avoid fake data.
    throw UnimplementedError('Join by token is not supported by the documented API');
  }

  // ---------- mappers ----------

  List<dynamic> _unwrapList(dynamic data) {
    if (data is Map && data['data'] is List) return List<dynamic>.from(data['data']);
    if (data is List) return List<dynamic>.from(data);
    throw DioException( requestOptions: RequestOptions(path: ''), error: 'Unexpected list response shape');
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) return Map<String, dynamic>.from(data['data']);
      return data;
    }
    throw DioException( requestOptions: RequestOptions(path: ''), error: 'Unexpected map response shape');
  }

  GroupSummary _mapGroupSummary(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return GroupSummary(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description'] as String?,
      createdAt: _parseDate(map['createdAt']),
      memberCount: _toInt(map['memberCount']),
      role: map['role']?.toString() ?? '',
      assignedQuizzesCount: _toInt(map['assignedQuizzesCount']),
    );
  }

  GroupDetail _mapGroupDetail(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return GroupDetail(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description'] as String?,
      createdAt: _parseDate(map['createdAt']),
      creatorId: map['creatorId']?.toString() ?? '',
      totalMembers: _toInt(map['totalMembers'] ?? map['memberCount']),
      totalAssignedQuizzes: _toInt(map['totalAssignedQuizzes'] ?? map['assignedQuizzesCount']),
      myRole: map['myRole']?.toString() ?? map['role']?.toString() ?? '',
    );
  }

  Member _mapMember(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return Member(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email'] as String?,
      role: map['role']?.toString() ?? '',
      joinedAt: _parseDate(map['joinedAt']),
    );
  }

  AssignedQuiz _mapAssignedQuiz(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return AssignedQuiz(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description'] as String?,
      author: map['author']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      assignedAt: _parseDate(map['assignedAt'] ?? map['createdAt']),
    );
  }

  RankingEntry _mapRankingEntry(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return RankingEntry(
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      completedCount: _toInt(map['completedCount']),
      totalScore: _toInt(map['totalScore']),
      position: _toInt(map['position']),
    );
  }

  DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
