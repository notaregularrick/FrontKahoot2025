import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/network/dio_provider.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';
import 'package:frontkahoot2526/features/games/multiplayer/infrastructure/multiplayer_game_repository.dart';

// final multiplayerGameRepositoryProvider = Provider<IMultiplayerGameRepository>((ref) {
//   final repo = FakeGameRepositoryImpl();
//   ref.onDispose(() => repo.dispose());
//   return repo;
// });

final multiplayerGameRepositoryProvider = Provider<IMultiplayerGameRepository>((ref) {
  final repo = MultiplayerGameRepositoryImpl(ref.watch(dioProvider));
  ref.onDispose(() => repo.dispose());
  return repo;
});