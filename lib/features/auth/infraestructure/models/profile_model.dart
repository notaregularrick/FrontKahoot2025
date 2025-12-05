import '../../domain/entities/profile_entity.dart';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String description;
  final String userType;
  final String avatarUrl;
  final String theme;
  final String language;
  final int gameStreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.userType,
    required this.avatarUrl,
    required this.theme,
    required this.language,
    required this.gameStreak,
    required this.createdAt,
    required this.updatedAt,
  });

  // 1. DE MAPA A MODELO (Lectura)
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      description: json['description'] ?? '',
      userType: json['userType'] ?? 'Básico',
      gameStreak: json['gameStreak'] ?? 0,
      theme: json['theme'] ?? 'Día',
      language: json['language'] ?? 'Español',
      // Manejo seguro de fechas
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 2. DE MODELO A MAPA (Escritura)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'description': description,
      'userType': userType,
      'gameStreak': gameStreak,
      'theme': theme,
      'language': language,
      'createdAt': createdAt.toIso8601String(), // Importante para fechas
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      email: email,
      description: description,
      userType: userType,
      avatarUrl: avatarUrl,
      theme: theme,
      language: language,
      gameStreak: gameStreak,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
