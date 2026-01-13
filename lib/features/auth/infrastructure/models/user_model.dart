import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.userType,
    required super.createdAt,
  });

  // Constructor para leer el JSON que viene del Backend
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Manejo seguro de "userProfileDetails"
    final profileDetails = json['userProfileDetails'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      // Mapeamos el nombre que está dentro de userProfileDetails
      name: profileDetails?['name'] ?? json['username'] ?? 'Usuario',
      // Mapeamos el tipo
      userType: json['type'] ?? 'user',
      // Como este endpoint no devuelve fecha, ponemos la actual por defecto
      createdAt: DateTime.now(), 
    );
  }

  // Para enviar datos (si fuera necesario)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': userType,
    };
  }
  
  // Método de utilidad para convertir a Entidad pura
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