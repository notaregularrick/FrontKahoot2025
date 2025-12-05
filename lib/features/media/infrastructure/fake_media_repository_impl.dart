import 'dart:io';
import 'package:frontkahoot2526/core/domain/entities/media.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/media/domain/media_repository.dart';

class FakeMediaRepositoryImpl implements IMediaRepository {
  @override
  Future<Media> uploadMedia(File file) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      // Validar que el archivo existe
      if (!await file.exists()) {
        throw AppException(
          message: 'El archivo no existe',
          statusCode: 400,
        );
      }

      // Validar extensión del archivo
      final fileName = file.path.split(Platform.pathSeparator).last.toLowerCase();
      final validExtensions = ['.gif', '.webp', '.png', '.jpg', '.jpeg'];
      final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));

      if (!hasValidExtension) {
        throw AppException(
          message: 'Formato de archivo no válido. Solo se permiten: gif, webp, png, jpg',
          statusCode: 400,
        );
      }

      // Obtener información del archivo
      final fileStat = await file.stat();
      final fileSize = fileStat.size;

      // Determinar mimeType basado en la extensión
      String mimeType = 'image/jpeg';
      if (fileName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (fileName.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      // Generar ID único para el media
      final String generatedId = 'media_${DateTime.now().millisecondsSinceEpoch}';

      // Crear entidad Media con datos simulados
      final media = Media(
        id: generatedId,
        mimeType: mimeType,
        size: fileSize,
        originalName: fileName,
        createdAt: DateTime.now(),
      );

      // Reemplazar por llamada a la API real
      // ej
      // final dio = Dio();
      // final formData = FormData.fromMap({
      //   'file': await MultipartFile.fromFile(file.path),
      // });
      // final response = await dio.post('/media/upload', data: formData);
      // return Media.fromJson(response.data);

      return media;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error al subir el archivo',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  String getMediaUrl(String mediaId) {
    // Retornar URL mock (en producción sería la URL real del backend)
    return 'https://placehold.co/400/png?text=Media+$mediaId';
  }
}

