import 'package:dio/dio.dart';
import 'notifications_datasource.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/models/register_device_dto.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/models/unregister_device_dto.dart';

class NotificationsDatasourceImpl implements NotificationsDatasource {
  final Dio dio;

  NotificationsDatasourceImpl(this.dio);

  @override
  Future<void> registerDevice(RegisterDeviceDto dto) async {
    try {
      await dio.post('/notifications/register-device', data: dto.toJson());
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Datos del DTO inválidos');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Usuario no autenticado');
        }
        final msg = e.response?.data['message'];
        if (msg != null) throw Exception(msg);
      }
      throw Exception('Error al registrar dispositivo: $e');
    }
  }

  @override
  Future<void> unregisterDevice(UnregisterDeviceDto dto) async {
    try {
      await dio.delete('/notifications/unregister-device', data: dto.toJson());
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Falta token en el body');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Usuario no autenticado');
        }
        final msg = e.response?.data['message'];
        if (msg != null) throw Exception(msg);
      }
      throw Exception('Error al desregistrar dispositivo: $e');
    }
  }
}
