class ProfileEntity {
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

  ProfileEntity({
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


  /* Método para convertir un JSON en un objeto UserProfile
  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      description: json['description'],
      userType: json['userType'],
      avatarUrl: json['avatarUrl'],
      theme: json['theme'],
      language: json['language'],
      gameStreak: json['gameStreak'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }*/
}
