import 'dart:io';
import 'dart:typed_data';
import 'package:frontkahoot2526/core/domain/entities/media.dart';
import 'package:frontkahoot2526/core/domain/entities/media_theme.dart';
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
        throw AppException(message: 'El archivo no existe', statusCode: 400);
      }

      // Validar extensión del archivo
      final fileName = file.path
          .split(Platform.pathSeparator)
          .last
          .toLowerCase();
      final validExtensions = ['.gif', '.webp', '.png', '.jpg', '.jpeg'];
      final hasValidExtension = validExtensions.any(
        (ext) => fileName.endsWith(ext),
      );

      if (!hasValidExtension) {
        throw AppException(
          message:
              'Formato de archivo no válido. Solo se permiten: gif, webp, png, jpg',
          statusCode: 400,
        );
      }

      // Obtener información del archivo
      final fileStat = await file.stat();
      final fileSize = fileStat.size;

      // Determinar mimeType y format basado en la extensión
      String mimeType = 'image/jpeg';
      String format = 'jpg';
      if (fileName.endsWith('.png')) {
        mimeType = 'image/png';
        format = 'png';
      } else if (fileName.endsWith('.gif')) {
        mimeType = 'image/gif';
        format = 'gif';
      } else if (fileName.endsWith('.webp')) {
        mimeType = 'image/webp';
        format = 'webp';
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
        format = 'jpg';
      }

      // Generar ID único para el media
      final String generatedId =
          'asset_${DateTime.now().millisecondsSinceEpoch}';

      // Crear entidad Media con datos simulados según la estructura de la API
      final media = Media(
        assetId: generatedId,
        url: 'https://example.com/media/$generatedId.$format',
        mimeType: mimeType,
        size: fileSize,
        format: format,
        category: 'image',
      );

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
  Future<Media> uploadMediaFromBytes(Uint8List bytes) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    return Media(
      assetId: 'asset_${DateTime.now().millisecondsSinceEpoch}',
      url:
          'https://example.com/media/${DateTime.now().millisecondsSinceEpoch}.jpg',
      mimeType: 'image/jpeg',
      size: bytes.length,
      format: 'jpg',
      category: 'image',
    );
  }

  @override
  Future<List<MediaTheme>> getThemes() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));

    // Retornar datos simulados de temas
    return [
      const MediaTheme(
        assetId: 'theme_001',
        url: 'https://example.com/themes/tema1.webp',
        name: 'Tema 1',
        category: 'image',
        format: 'webp',
        size: 102400,
        mimeType: 'image/webp',
      ),
      const MediaTheme(
        assetId: 'theme_002',
        url: 'https://example.com/themes/tema2.webp',
        name: 'Tema 2',
        category: 'image',
        format: 'webp',
        size: 98765,
        mimeType: 'image/webp',
      ),
      const MediaTheme(
        assetId: 'theme_003',
        url: 'https://example.com/themes/tema3.webp',
        name: 'Tema 3',
        category: 'image',
        format: 'webp',
        size: 115200,
        mimeType: 'image/webp',
      ),
    ];
  }
}
