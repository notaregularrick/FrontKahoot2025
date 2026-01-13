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

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? userType,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        // Prefer profile.name, then username, then name
        name: json['profile']?['name']?.toString() ?? json['username']?.toString() ?? json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        // From roles array if present, else userType, fallback 'user'
        userType: (json['roles'] is List && (json['roles'] as List).isNotEmpty)
            ? (json['roles'] as List).first.toString()
            : (json['userType']?.toString() ?? 'user'),
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        userType: userType,
        createdAt: createdAt,
      );
}
