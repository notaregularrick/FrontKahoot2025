import 'package:frontkahoot2526/features/notifications/infrastructure/models/register_device_dto.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/models/unregister_device_dto.dart';

abstract class NotificationsDatasource {
  Future<void> registerDevice(RegisterDeviceDto dto);
  Future<void> unregisterDevice(UnregisterDeviceDto dto);
}
