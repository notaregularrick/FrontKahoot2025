import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.userType,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profileDetails = json['userProfileDetails'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: profileDetails?['name'] ?? json['username'] ?? 'Usuario',
      userType: json['type'] ?? 'user',
      createdAt: DateTime.now(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': userType,
    };
  }
  
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      userType: userType,
      createdAt: createdAt,
    );
  }
}