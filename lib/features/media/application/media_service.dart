import 'dart:io';
import 'package:frontkahoot2526/core/domain/entities/media.dart';
import 'package:frontkahoot2526/features/media/domain/media_repository.dart';

class MediaService {
  final IMediaRepository repository;

  MediaService(this.repository);

  /// Sube un archivo multimedia y retorna la entidad Media con metadatos
  Future<Media> uploadMedia(File file) {
    return repository.uploadMedia(file);
  }

  /// Obtiene la URL para acceder a un archivo multimedia por su ID
  String getMediaUrl(String mediaId) {
    return repository.getMediaUrl(mediaId);
  }
}

