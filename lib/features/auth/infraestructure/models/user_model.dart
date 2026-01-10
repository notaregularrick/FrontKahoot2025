import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final List<String> roles;

  UserModel({
    required super.id,
    required super.email,
    required super.name,
    required this.roles,
    String userType = 'default', 
    DateTime? createdAt, 
  }) : super(
          userType: userType,
          createdAt: createdAt ?? DateTime.now(), 
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'Usuario',
      roles: List<String>.from(json['roles'] ?? ['user']),
      userType: (json['roles'] as List?)?.contains('admin') == true ? 'admin' : 'default',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'roles': roles,
      'userType': userType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      userType: userType,
      createdAt: createdAt,
    );
  }
}