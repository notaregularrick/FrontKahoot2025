import 'package:frontkahoot2526/core/services/secure_storage_service.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class CreateGameUseCase {
  final IMultiplayerGameRepository gameRepository;
  final SecureStorageService _storage;
  //Necesita reposirotio de auth para obtener el jwt

  CreateGameUseCase(this.gameRepository) : _storage = SecureStorageService.instance;

  Future<String> execute(String quizId) async{
    final jwt = await _storage.getToken();
    if (jwt == null || jwt.isEmpty) {
      throw Exception('No hay sesión activa (token faltante)');
    }

    // TODO: obtener nickname host real desde perfil/auth; placeholder por ahora
    final String nickname = 'Host';

    final pin = await gameRepository.createGame(quizId);
    
    await gameRepository.connectToGame(pin, nickname, jwt, GameRole.host);

    return pin;
  }
}