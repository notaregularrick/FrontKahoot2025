import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_session.dart';

class ListenGameSessionUseCase {
  final IMultiplayerGameRepository repository;

  ListenGameSessionUseCase(this.repository);

  Stream<MultiplayerGameSession> execute() {
    return repository.gameStream;
  }
}