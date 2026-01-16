import 'package:frontkahoot2526/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/datasource/notifications_datasource.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/models/register_device_dto.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/models/unregister_device_dto.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDatasource datasource;

  NotificationsRepositoryImpl(this.datasource);

  @override
  Future<void> registerDevice(String token) async {
    final dto = RegisterDeviceDto(
      token: token,
      deviceType: 'android', // Hardcodeado para Android
    );
    await datasource.registerDevice(dto);
  }

  @override
  Future<void> unregisterDevice(String token) async {
    final dto = UnregisterDeviceDto(token: token);
    await datasource.unregisterDevice(dto);
  }
}
