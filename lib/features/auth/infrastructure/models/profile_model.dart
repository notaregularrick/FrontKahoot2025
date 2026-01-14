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
    // Si la respuesta viene envuelta en "user", desenvolvemos primero
    final userJson = json.containsKey('user') ? json['user'] as Map<String, dynamic> : json;
    
    // Extraemos los sub-objetos
    final details = userJson['userProfileDetails'] as Map<String, dynamic>?;
    final prefs = userJson['preferences'] as Map<String, dynamic>?;

    return ProfileModel(
      id: userJson['id'] ?? '',
      email: userJson['email'] ?? '',
      
      // Mapeo desde userProfileDetails
      name: details?['name'] ?? userJson['username'] ?? 'Usuario',
      description: details?['description'] ?? '',
      avatarUrl: details?['avatarAssetUrl'] ?? '',
      
      // Otros campos
      userType: userJson['type'] ?? 'user',
      gameStreak: 0, // El backend actual no parece devolver racha, ponemos 0 por defecto
      
      // Preferencias
      theme: prefs?['theme'] ?? 'light',
      language: 'es', // Valor por defecto o extraer si viene en el JSON
      
      createdAt: DateTime.now(), // El JSON no trae fechas, usamos actuales
      updatedAt: DateTime.now(),
    );
  }

  // Método para convertir a Entidad (si no heredas directamente, aunque aquí sí)
  ProfileEntity toEntity() => this;
}