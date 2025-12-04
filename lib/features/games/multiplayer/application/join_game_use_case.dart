import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class JoinGameUseCase {
  final IMultiplayerGameRepository gameRepository;
  //Luego necesita el repositorio para jwt de autenticacion

  JoinGameUseCase(this.gameRepository);

  Future<void> execute(String pin, String nickname, GameRole role) async{
    if(nickname.isEmpty) {
      throw AppException(message: 'El nickname no puede estar vacío');
    }
    if(pin.length != 6) {
      throw AppException(message: 'El PIN debe tener 6 dígitos');
    }

    final String jwt = 'jwt-prueba';//Aquí va lógica para obtener jwt

    return await gameRepository.connectToGame(pin, nickname, jwt, role);
  }
}
