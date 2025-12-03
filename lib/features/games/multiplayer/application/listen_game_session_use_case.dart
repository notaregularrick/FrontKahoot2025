import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class ListeGameSessionUseCase {
  final IMultiplayerGameRepository repository;

  ListeGameSessionUseCase(this.repository);

  Stream<GameSession> execute() {
    return repository.gameStream;
  }
}