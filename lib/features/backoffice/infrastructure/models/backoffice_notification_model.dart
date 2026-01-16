import '../../domain/entities/backoffice_notification.dart';
import 'backoffice_response_model.dart'; // Para BackofficePaginationModel

class BackofficeSenderModel extends BackofficeSenderEntity {
  const BackofficeSenderModel({
    required super.id,
    required super.name,
    required super.email,
    super.imageUrl,
  });

  factory BackofficeSenderModel.fromJson(Map<String, dynamic> json) {
    return BackofficeSenderModel(
      // Según tu JSON, las claves vienen con Mayúscula inicial
      id: json['Id'] ?? json['id'] ?? '', 
      name: json['name'] ?? 'Desconocido',
      email: json['email'] ?? '',
      imageUrl: json['ImageUrl'] ?? json['avatarUrl'],
    );
  }
}

class BackofficeNotificationModel extends BackofficeNotificationEntity {
  const BackofficeNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.sender,
  });

  factory BackofficeNotificationModel.fromJson(Map<String, dynamic> json) {
    return BackofficeNotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sin título',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      sender: BackofficeSenderModel.fromJson(json['sender'] ?? {}),
    );
  }
}

class BackofficeNotificationsResponseModel extends BackofficeNotificationsResponseEntity {
  const BackofficeNotificationsResponseModel({
    required super.data,
    required super.pagination,
  });

  factory BackofficeNotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return BackofficeNotificationsResponseModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BackofficeNotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      // Reutilizamos el modelo de paginación que ya creamos para usuarios
      pagination: BackofficePaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}