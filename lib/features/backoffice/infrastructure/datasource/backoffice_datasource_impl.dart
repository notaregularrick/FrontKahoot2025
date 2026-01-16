import 'package:dio/dio.dart';
import '../models/backoffice_notification_model.dart';
import 'backoffice_datasource.dart';
import '../models/backoffice_response_model.dart';

class BackofficeDatasourceImpl implements BackofficeDatasource {
  final Dio dio;

  BackofficeDatasourceImpl(this.dio);

  @override
  Future<BackofficeResponseModel> getUsers({
    String? name,
    String? userId,
    int page = 1,
    int limit = 20,
    String orderBy = 'createdAt',
    String order = 'asc',
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'orderBy': orderBy,
        'order': order,
      };

      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (userId != null && userId.isNotEmpty) queryParams['userId'] = userId;

      final response = await dio.get(
        '/backoffice/users',
        queryParameters: queryParams,
      );

      return BackofficeResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('No autorizado: Se requieren permisos de administrador.');
        }
        if (e.response?.statusCode == 400) {
          throw Exception('Petición incorrecta: Verifique los filtros.');
        }
      }
      throw Exception('Error al cargar usuarios: $e');
    }
  }

  @override
  Future<BackofficeUserModel> blockUser(String userId) async {
    try {
      // PATCH /backoffice/blockUser/:userid
      final response = await dio.patch('/backoffice/blockUser/$userId');
      
      // La respuesta es el objeto de usuario actualizado
      return BackofficeUserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Usuario no encontrado o ID inválido.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('No autorizado: Solo administradores pueden bloquear usuarios.');
        }
      }
      throw Exception('Error al bloquear usuario: $e');
    }
  }

  @override
  Future<BackofficeUserModel> unblockUser(String userId) async {
    try {
      // PATCH /backoffice/unblockUser/:userid
      final response = await dio.patch('/backoffice/unblockUser/$userId');
      return BackofficeUserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) throw Exception('Usuario no encontrado.');
        if (e.response?.statusCode == 401) throw Exception('No autorizado.');
      }
      throw Exception('Error al desbloquear usuario: $e');
    }
  }

  @override
  Future<BackofficeUserModel> giveAdmin(String userId) async {
    try {
      // PATCH /backoffice/giveAdmin/:userid
      final response = await dio.patch('/backoffice/giveAdmin/$userId');
      return BackofficeUserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) throw Exception('Usuario no encontrado.');
        if (e.response?.statusCode == 401) throw Exception('No autorizado.');
      }
      throw Exception('Error al otorgar permisos de admin: $e');
    }
  }

  @override
  Future<BackofficeUserModel> removeAdmin(String userId) async {
    try {
      // PATCH /backoffice/removeAdmin/:userid
      final response = await dio.patch('/backoffice/removeAdmin/$userId');
      return BackofficeUserModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) throw Exception('Usuario no encontrado.');
        if (e.response?.statusCode == 401) throw Exception('No autorizado.');
      }
      throw Exception('Error al quitar permisos de admin: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      // DELETE /backoffice/user/:userid
      final response = await dio.delete('/backoffice/user/$userId');
      
      // Esperamos 204 No Content (o 200 OK dependiendo del back)
      if (response.statusCode != 200 && response.statusCode != 204) {
         throw Exception('Error inesperado al eliminar.');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) throw Exception('Usuario no encontrado.');
        if (e.response?.statusCode == 401) throw Exception('No autorizado.');
      }
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  @override
  Future<BackofficeNotificationsResponseModel> getMassNotifications({
    String? userId,
    int page = 1,
    int limit = 20,
    String orderBy = 'createdAt',
    String order = 'asc',
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'orderBy': orderBy,
        'order': order,
      };

      if (userId != null && userId.isNotEmpty) queryParams['userId'] = userId;

      final response = await dio.get(
        '/backoffice/massNotifications',
        queryParameters: queryParams,
      );

      return BackofficeNotificationsResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('No autorizado: Se requieren permisos de administrador.');
        }
      }
      throw Exception('Error al cargar notificaciones: $e');
    }
  }
}