import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/media/application/media_service.dart';
import 'package:frontkahoot2526/features/media/presentation/providers/media_repository_provider.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  final repository = ref.read(mediaRepositoryProvider);
  return MediaService(repository);
});

