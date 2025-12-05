import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class ChangeNextPhaseUseCase {
  final IMultiplayerGameRepository repository;

  ChangeNextPhaseUseCase(this.repository);
  Future<void> execute() {
    return repository.nextPhase();
  }
}