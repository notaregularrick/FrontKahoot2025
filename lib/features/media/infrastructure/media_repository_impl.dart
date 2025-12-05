import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/media.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/media/domain/media_repository.dart';

// TODO: Mover a configuración de entorno
const String _baseUrl = 'http://localhost:3000'; // Cambiar por BACKEND

class MediaRepositoryImpl implements IMediaRepository {
  final Dio _dio;

  MediaRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  @override
  Future<Media> uploadMedia(File file) async {
    try {
      if (!await file.exists()) {
        throw AppException(
          message: 'El archivo no existe',
          statusCode: 400,
        );
      }

      final fileName = file.path.split('/').last.toLowerCase();
      final validExtensions = ['.gif', '.webp', '.png', '.jpg', '.jpeg'];
      final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));
      
      if (!hasValidExtension) {
        throw AppException(
          message: 'Formato de archivo no válido. Solo se permiten: gif, webp, png, jpg',
          statusCode: 400,
        );
      }

      // Crear FormData con el archivo
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      // Realizar POST request
      final response = await _dio.post(
        '/media/upload',
        data: formData,
      );

      // Validar respuesta
      if (response.statusCode == 201) {
        return Media.fromJson(response.data);
      } else {
        throw AppException(
          message: 'Error al subir el archivo',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        String message = 'Error al subir el archivo';
        
        if (statusCode == 400) {
          message = 'Datos de archivo inválidos';
        } else if (statusCode == 404) {
          message = 'El recurso no existe o no es accesible';
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
          message: 'Error de conexión al subir el archivo',
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error inesperado al subir el archivo',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  String getMediaUrl(String mediaId) {
    return '$_baseUrl/media/$mediaId';
  }
}

