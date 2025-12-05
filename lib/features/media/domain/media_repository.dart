import 'dart:io';
import 'package:frontkahoot2526/core/domain/entities/media.dart';

abstract class IMediaRepository {
  /// Sube un archivo multimedia al servidor
  /// Retorna la entidad media con los metadatos del archivo subido
  Future<Media> uploadMedia(File file);

  /// Obtiene la URL para acceder a un archivo multimedia por su ID
  /// Retorna la URL completa para hacer GET /media/:mediaId
  String getMediaUrl(String mediaId);
}

