import 'backoffice_user.dart'; // Importamos para reutilizar la entidad de paginación si se separó, o redefinimos

class BackofficeSenderEntity {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  const BackofficeSenderEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });
}

class BackofficeNotificationEntity {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final BackofficeSenderEntity sender;

  const BackofficeNotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.sender,
  });
}

// Reutilizamos la lógica de paginación
class BackofficeNotificationsResponseEntity {
  final List<BackofficeNotificationEntity> data;
  final BackofficePaginationEntity pagination;

  const BackofficeNotificationsResponseEntity({
    required this.data,
    required this.pagination,
  });
}