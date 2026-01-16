import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/network/dio_provider.dart';
import 'package:frontkahoot2526/features/games/singleplayer/infrastructure/singleplayer_api_repository.dart';

final singleplayerRepositoryProvider = Provider<SingleplayerApiRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SingleplayerApiRepository(dio);
});
