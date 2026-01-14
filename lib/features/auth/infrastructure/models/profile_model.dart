import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
   ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.description,
    required super.userType,
    required super.gameStreak,
    required super.theme,
    required super.language,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final userJson = json.containsKey('user') ? json['user'] as Map<String, dynamic> : json;
    
    final details = userJson['userProfileDetails'] as Map<String, dynamic>?;
    final prefs = userJson['preferences'] as Map<String, dynamic>?;

    return ProfileModel(
      id: userJson['id'] ?? '',
      email: userJson['email'] ?? '',
      
      name: details?['name'] ?? userJson['username'] ?? 'Usuario',
      description: details?['description'] ?? '',
      avatarUrl: details?['avatarAssetUrl'] ?? '',
      
      userType: userJson['type'] ?? 'user',
      gameStreak: 0,
      
      theme: prefs?['theme'] ?? 'light',
      language: 'es', 
      
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ProfileEntity toEntity() => this;
}