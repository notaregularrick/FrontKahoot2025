import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/network/dio_provider.dart';
import 'package:frontkahoot2526/features/media/domain/media_repository.dart';
import 'package:frontkahoot2526/features/media/infrastructure/media_repository_impl.dart';
// import 'package:frontkahoot2526/features/media/infrastructure/fake_media_repository_impl.dart';

final mediaRepositoryProvider = Provider<IMediaRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MediaRepositoryImpl(dio: dio);
  // Para desarrollo sin backend: return FakeMediaRepositoryImpl();
});
