import '../../domain/entities/backoffice_user.dart';

class BackofficeUserModel extends BackofficeUserEntity {
  const BackofficeUserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    super.description,
    required super.userType,
    super.avatarUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.isAdmin,
    required super.status,
  });

  factory BackofficeUserModel.fromJson(Map<String, dynamic> json) {
    return BackofficeUserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      description: json['description'],
      userType: json['userType'] ?? 'user',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now() 
          : DateTime.now(),
      isAdmin: json['isAdmin'] ?? false,
      status: json['status'] ?? 'Active',
    );
  }
}

class BackofficePaginationModel extends BackofficePaginationEntity {
  const BackofficePaginationModel({
    required super.page,
    required super.limit,
    required super.totalCount,
    required super.totalPages,
  });

  factory BackofficePaginationModel.fromJson(Map<String, dynamic> json) {
    return BackofficePaginationModel(
      page: json['page'] is int ? json['page'] : int.tryParse(json['page'].toString()) ?? 1,
      limit: json['limit'] is int ? json['limit'] : int.tryParse(json['limit'].toString()) ?? 20,
      totalCount: json['totalCount'] is int ? json['totalCount'] : int.tryParse(json['totalCount'].toString()) ?? 0,
      totalPages: json['totalPages'] is int ? json['totalPages'] : int.tryParse(json['totalPages'].toString()) ?? 0,
    );
  }
}

class BackofficeResponseModel extends BackofficeResponseEntity {
  const BackofficeResponseModel({
    required super.data,
    required super.pagination,
  });

  factory BackofficeResponseModel.fromJson(Map<String, dynamic> json) {
    return BackofficeResponseModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BackofficeUserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: BackofficePaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}