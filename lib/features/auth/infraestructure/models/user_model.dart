import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String userType;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        userType: json['userType'],
        createdAt: json['createdAt'],
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        userType: userType,
        createdAt: createdAt,
      );
}
