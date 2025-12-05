import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/media/domain/media_repository.dart';
import 'package:frontkahoot2526/features/media/infrastructure/fake_media_repository_impl.dart';

final mediaRepositoryProvider = Provider<IMediaRepository>((ref) {
  // Cambiar a MediaRepositoryImpl() cuando el backend esté disponible
  return FakeMediaRepositoryImpl();
  // return MediaRepositoryImpl();
});

