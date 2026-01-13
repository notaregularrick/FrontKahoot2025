import 'dart:io';
import 'package:frontkahoot2526/core/domain/entities/media.dart';
import 'package:frontkahoot2526/core/domain/entities/media_theme.dart';

abstract class IMediaRepository {
  /// Sube un archivo multimedia al servidor
  /// Endpoint: POST /media/upload
  /// Retorna la entidad Media con los metadatos del archivo subido
  Future<Media> uploadMedia(File file);

  /// Obtiene la lista de temas multimedia disponibles
  /// Endpoint: GET /media/themes
  /// Retorna lista de MediaTheme con URLs al CDN o data URI (Base64)
  Future<List<MediaTheme>> getThemes();
}
