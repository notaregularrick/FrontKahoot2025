class GroupSummary {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int memberCount;
  final String role; // e.g. admin|teacher|student
  final int assignedQuizzesCount;

  GroupSummary({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.memberCount,
    required this.role,
    required this.assignedQuizzesCount,
  });
}

class Member {
  final String id;
  final String name;
  final String? email;
  final String role;
  final DateTime joinedAt;

  Member({required this.id, required this.name, this.email, required this.role, required this.joinedAt});
}

class AssignedQuiz {
  final String id;
  final String title;
  final String? description;
  final String author;
  final String status; // draft|published
  final DateTime assignedAt;

  AssignedQuiz({required this.id, required this.title, this.description, required this.author, required this.status, required this.assignedAt});
}

class RankingEntry {
  final String userId;
  final String userName;
  final int completedCount;
  final int totalScore;
  final int position;

  RankingEntry({required this.userId, required this.userName, required this.completedCount, required this.totalScore, required this.position});
}

class GroupDetail {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String creatorId;
  final int totalMembers;
  final int totalAssignedQuizzes;
  final String myRole;

  GroupDetail({required this.id, required this.name, this.description, required this.createdAt, required this.creatorId, required this.totalMembers, required this.totalAssignedQuizzes, required this.myRole});
}
