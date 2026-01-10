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
    // Detalle no disponible; usar listado + datos derivados
    // ignore: avoid_print
    print('[groups][warn] fetchGroupDetail called for $groupId (endpoint not available)');
    throw UnimplementedError('Group detail endpoint not provided; use list summary + members/quizzes/ranking');
  }

  @override
  Future<List<Member>> fetchMembers(String groupId) async {
    // ignore: avoid_print
    print('[groups][members] GET /groups/$groupId/members');
    final res = await _dio.get('/groups/$groupId/members');
    // ignore: avoid_print
    print('[groups][members] status=${res.statusCode} body=${res.data.runtimeType}');
    final data = _unwrapList(res.data);
    return data.map(_mapMember).toList();
  }

  @override
  Future<List<AssignedQuiz>> fetchQuizzes(String groupId) async {
    // ignore: avoid_print
    print('[groups][quizzes] GET /groups/$groupId/quizzes');
    final res = await _dio.get('/groups/$groupId/quizzes');
    // ignore: avoid_print
    print('[groups][quizzes] status=${res.statusCode} body=${res.data.runtimeType}');
    final data = _unwrapList(res.data);
    return data.map(_mapAssignedQuiz).toList();
  }

  @override
  Future<List<RankingEntry>> fetchRanking(String groupId) async {
    // ignore: avoid_print
    print('[groups][ranking] GET /groups/$groupId/leaderboard');
    final res = await _dio.get('/groups/$groupId/leaderboard');
    // ignore: avoid_print
    print('[groups][ranking] status=${res.statusCode} body=${res.data.runtimeType}');
    final data = _unwrapList(res.data);
    return data.map(_mapRankingEntry).toList();
  }

  @override
  Future<List<RankingEntry>> fetchQuizLeaderboard(String groupId, String quizId) async {
    // ignore: avoid_print
    print('[groups][quiz-leaderboard] GET /groups/$groupId/quizzes/$quizId/leaderboard');
    final res = await _dio.get('/groups/$groupId/quizzes/$quizId/leaderboard');
    // ignore: avoid_print
    print('[groups][quiz-leaderboard] status=${res.statusCode} bodyType=${res.data.runtimeType} body=${res.data}');
    final raw = res.data;
    final data = _unwrapLeaderboard(raw);
    // If empty, return gracefully; UI will show no results
    if (data.isEmpty) return <RankingEntry>[];
    return data.map(_mapRankingEntry).toList();
  }

  // Attempt to recursively unwrap a leaderboard list from arbitrary nesting
  List<dynamic> _unwrapLeaderboard(dynamic raw) {
    try {
      if (raw is List) return List<dynamic>.from(raw);
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw as Map);
        // Common keys first
        for (final key in const ['data', 'leaderboard', 'results', 'items', 'list', 'topPlayers']) {
          final val = map[key];
          final ls = _unwrapLeaderboard(val);
          if (ls.isNotEmpty) return ls;
        }
        // Fallback: search all values
        for (final val in map.values) {
          final ls = _unwrapLeaderboard(val);
          if (ls.isNotEmpty) return ls;
        }
      }
    } catch (_) {
      // swallow and return empty to let caller raise a clearer error
    }
    return <dynamic>[];
  }

  @override
  Future<List<SimpleQuiz>> fetchMyCreations() async {
    // ignore: avoid_print
    print('[library][my-creations] GET /library/my-creations');
    final res = await _dio.get('/library/my-creations');
    // ignore: avoid_print
    print('[library][my-creations] status=${res.statusCode} body=${res.data.runtimeType}');
    final data = _unwrapList(res.data);
    return data.map(_mapSimpleQuiz).toList();
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
  Future<void> assignQuiz(String groupId, String quizId, {String? availableFrom, String? availableUntil}) async {
    final payload = <String, dynamic>{'quizId': quizId};
    if (availableFrom != null && availableFrom.isNotEmpty) payload['availableFrom'] = availableFrom;
    if (availableUntil != null && availableUntil.isNotEmpty) payload['availableUntil'] = availableUntil;
    // ignore: avoid_print
    print('[groups][assign] POST /groups/$groupId/quizzes payload=$payload');
    await _dio.post('/groups/$groupId/quizzes', data: payload);
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
  Future<String> generateInviteLink(String groupId, {required String expiresIn}) async {
    // ignore: avoid_print
    print('[groups][invite] POST /groups/$groupId/invitations expiresIn=$expiresIn');
    final res = await _dio.post('/groups/$groupId/invitations', data: {
      'expiresIn': expiresIn,
    });
    // ignore: avoid_print
    print('[groups][invite] status=${res.statusCode} body=${res.data.runtimeType}');
    final map = _unwrapMap(res.data);
    return map['invitationLink']?.toString() ?? '';
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
    final role = (map['role']?.toString() ?? '').toLowerCase();
    return GroupSummary(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description'] as String?,
      createdAt: _parseDate(map['createdAt']),
      memberCount: _toInt(map['memberCount']),
      role: role,
      assignedQuizzesCount: _toInt(map['assignedQuizzesCount']),
    );
  }

  GroupDetail _mapGroupDetail(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    final myRole = (map['myRole']?.toString() ?? map['role']?.toString() ?? '').toLowerCase();
    return GroupDetail(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description'] as String?,
      createdAt: _parseDate(map['createdAt']),
      creatorId: map['creatorId']?.toString() ?? '',
      totalMembers: _toInt(map['totalMembers'] ?? map['memberCount']),
      totalAssignedQuizzes: _toInt(map['totalAssignedQuizzes'] ?? map['assignedQuizzesCount']),
      myRole: myRole,
    );
  }

  Member _mapMember(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return Member(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email'] as String?,
      role: (map['role']?.toString() ?? '').toLowerCase(),
      joinedAt: _parseDate(map['joinedAt']),
    );
  }

  AssignedQuiz _mapAssignedQuiz(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return AssignedQuiz(
      id: map['id']?.toString() ?? '',
      quizId: map['quizId']?.toString(),
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

  SimpleQuiz _mapSimpleQuiz(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    return SimpleQuiz(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
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
