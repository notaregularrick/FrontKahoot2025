import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/media.dart';
import 'package:frontkahoot2526/core/domain/entities/media_theme.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/media/domain/media_repository.dart';

class MediaRepositoryImpl implements IMediaRepository {
  final Dio _dio;

  MediaRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Media> uploadMedia(File file) async {
    try {
      print('[MEDIA UPLOAD] Iniciando subida de archivo');
      print('[MEDIA UPLOAD] Ruta del archivo: ${file.path}');

      if (!await file.exists()) {
        print('[MEDIA UPLOAD] ERROR: El archivo no existe');
        throw AppException(message: 'El archivo no existe', statusCode: 400);
      }

      final fileStat = await file.stat();
      print('[MEDIA UPLOAD] Tamaño del archivo: ${fileStat.size} bytes');

      final fileName = file.path
          .split(Platform.pathSeparator)
          .last
          .toLowerCase();
      print('[MEDIA UPLOAD] Nombre del archivo: $fileName');

      final validExtensions = ['.gif', '.webp', '.png', '.jpg', '.jpeg'];
      final hasValidExtension = validExtensions.any(
        (ext) => fileName.endsWith(ext),
      );

      if (!hasValidExtension) {
        print('[MEDIA UPLOAD] ERROR: Extensión no válida');
        throw AppException(
          message:
              'Formato de archivo no válido. Solo se permiten: gif, webp, png, jpg',
          statusCode: 400,
        );
      }

      // Crear FormData con el archivo
      //
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      print('[MEDIA UPLOAD] URL base de Dio: ${_dio.options.baseUrl}');
      print('[MEDIA UPLOAD] Endpoint: /media/upload');
      print('[MEDIA UPLOAD] Enviando request...');

      // Realizar POST request a /media/upload
      //lamada para subir la imagen al backend usando dio
      final response = await _dio.post('/media/upload', data: formData);

      print(
        '[MEDIA UPLOAD] Respuesta recibida - Status: ${response.statusCode}',
      );
      print('[MEDIA UPLOAD] Respuesta data: ${response.data}');

      // Validar respuesta 201 Created
      if (response.statusCode == 201) {
        print('[MEDIA UPLOAD] Subida exitosa');
        print('[MEDIA UPLOAD] Respuesta data: ${response.data}');
        return Media.fromJson(response.data);
      } else {
        print(
          '[MEDIA UPLOAD] ERROR: Código de respuesta inesperado: ${response.statusCode}',
        );
        throw AppException(
          message: 'Error al subir el archivo (código: ${response.statusCode})',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      print('[MEDIA UPLOAD] DioException capturada');
      print('[MEDIA UPLOAD] Tipo de error: ${e.type}');
      print('[MEDIA UPLOAD] Mensaje: ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final serverData = e.response?.data?.toString() ?? 'Sin datos';

        print('[MEDIA UPLOAD] Status code del servidor: $statusCode');
        print('[MEDIA UPLOAD] Respuesta del servidor: $serverData');

        String message;

        if (statusCode == 400) {
          message = 'Datos de archivo inválidos: $serverData';
        } else if (statusCode == 404) {
          message = 'Endpoint /media/upload no encontrado en el servidor';
        } else if (statusCode == 401) {
          message = 'No autorizado - Token inválido o expirado';
        } else if (statusCode == 413) {
          message = 'El archivo es demasiado grande';
        } else if (statusCode == 500) {
          message = 'Error interno del servidor: $serverData';
        } else {
          message = 'Error del servidor (código: $statusCode): $serverData';
        }

        throw AppException(
          message: message,
          statusCode: statusCode,
          error: serverData,
        );
      } else {
        print('[MEDIA UPLOAD] Sin respuesta del servidor');
        print('[MEDIA UPLOAD] Error de conexión: ${e.message}');

        String connectionError = 'Error de conexión';
        if (e.type == DioExceptionType.connectionTimeout) {
          connectionError =
              'Tiempo de conexión agotado - El servidor no responde';
        } else if (e.type == DioExceptionType.connectionError) {
          connectionError =
              'No se puede conectar al servidor - Verifica que el backend esté corriendo';
        } else if (e.type == DioExceptionType.unknown) {
          connectionError = 'Error de red: ${e.message}';
        }

        throw AppException(
          message: connectionError,
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
      print('[MEDIA UPLOAD] Excepción no manejada: ${e.runtimeType}');
      print('[MEDIA UPLOAD] Mensaje: $e');

      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  Future<Media> uploadMediaFromBytes(Uint8List bytes) async {
    try {
      // Realizar POST request a /media/upload
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'image.jpg'),
      });
      final response = await _dio.post('/media/upload', data: formData);
      if (response.statusCode == 201) {
        return Media.fromJson(response.data);
      } else {
        throw AppException(
          message: 'Error al subir el archivo',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error inesperado: ${e.toString()}',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  Future<List<MediaTheme>> getThemes() async {
    try {
      // Realizar GET request a /media/themes
      final response = await _dio.get('/media/themes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => MediaTheme.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw AppException(
          message: 'Error al obtener los temas',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        String message = 'Error al obtener los temas';

        if (statusCode == 404) {
          message = 'No se encontraron temas disponibles';
        } else if (statusCode == 401) {
          message = 'No autorizado';
        }

        throw AppException(
          message: message,
          statusCode: statusCode,
          error: e.response?.data?.toString(),
        );
      } else {
        throw AppException(
          message: 'Error de conexión al obtener los temas',
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error inesperado al obtener los temas',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }
}
