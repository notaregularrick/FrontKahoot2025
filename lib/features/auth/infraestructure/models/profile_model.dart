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

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        description: json["description"],
        userType: json["userType"],
        avatarUrl: json["avatarUrl"],
        theme: json["theme"],
        language: json["language"],
        gameStreak: json["gameStreak"],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "name": name,
  //       "description": description,
  //       "avatarUrl": avatarUrl,
  //       "userType": userType,
  //       "language": language,
  //     };

  Map<String, dynamic> toJson() => {
        "id": id, 
        "name": name,
        "email": email, 
        "description": description,
        "userType": userType,
        "avatarUrl": avatarUrl,
        "theme": theme, 
        "language": language,
        "gameStreak": gameStreak, 
        "createdAt": createdAt.toIso8601String(), 
        "updatedAt": updatedAt.toIso8601String(), 
      };

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
