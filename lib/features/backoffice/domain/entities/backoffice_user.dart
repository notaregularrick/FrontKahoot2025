class BackofficeUserEntity {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? description;
  final String userType;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAdmin;
  final String status; // "Active" | "Blocked"

  const BackofficeUserEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.description,
    required this.userType,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isAdmin,
    required this.status,
  });
}

class BackofficePaginationEntity {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;

  const BackofficePaginationEntity({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
  });
}

class BackofficeResponseEntity {
  final List<BackofficeUserEntity> data;
  final BackofficePaginationEntity pagination;

  const BackofficeResponseEntity({
    required this.data,
    required this.pagination,
  });
}