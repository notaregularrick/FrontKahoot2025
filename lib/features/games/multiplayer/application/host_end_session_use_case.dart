import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class HostEndSessionUseCase {
  final IMultiplayerGameRepository repository;

  HostEndSessionUseCase(this.repository);
  Future<void> execute() {
    return repository.endSession();
  }
}
