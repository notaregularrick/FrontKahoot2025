import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/core/services/secure_storage_service.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class JoinGameUseCase {
  final IMultiplayerGameRepository gameRepository;
  final SecureStorageService _storage;
  //Luego necesita el repositorio para jwt de autenticacion

  JoinGameUseCase(this.gameRepository) : _storage = SecureStorageService.instance;

  Future<void> execute(String pin, String nickname, GameRole role) async{
    if(nickname.isEmpty) {
      throw AppException(message: 'El nickname no puede estar vacío');
    }
    // if(pin.length != 6) {
    //   throw AppException(message: 'El PIN debe tener 6 dígitos');
    // }

    final jwt = await _storage.getToken();
    if (jwt == null || jwt.isEmpty) {
      throw AppException(message: 'No hay sesión activa (token faltante)');
    }

    return await gameRepository.connectToGame(pin, nickname, jwt, role);
  }
}
