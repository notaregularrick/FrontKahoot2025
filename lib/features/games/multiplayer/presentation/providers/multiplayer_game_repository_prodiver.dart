import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';
import 'package:frontkahoot2526/features/games/multiplayer/infrastructure/fake_multiplayer_game_repository.dart';

final multiplayerGameRepositoryProvider = Provider<IMultiplayerGameRepository>((ref) {
  final repo = FakeGameRepositoryImpl();
  ref.onDispose(() => repo.dispose());
  return repo;
});