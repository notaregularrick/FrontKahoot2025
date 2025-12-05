import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class CreateGameUseCase {
  final IMultiplayerGameRepository gameRepository;
  //Necesita reposirotio de auth para obtener el jwt

  CreateGameUseCase(this.gameRepository);

  Future<String> execute(String quizId) async{
    final String jwt = 'jwt-prueba'; //Aquí va lógica para obtener jwt
    //valida jwt

    final String nickname = 'NicknameHost'; //Aquí va lógica para obtener nickname host con el jwt

    final pin = await gameRepository.createGame(quizId);
    
    await gameRepository.connectToGame(pin, nickname, jwt, GameRole.host);

    return pin;
  }
}