import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class StartGameUseCase {
  final IMultiplayerGameRepository repository;

  StartGameUseCase(this.repository);
  Future<void> execute() {
    return repository.startGame();
  }
}