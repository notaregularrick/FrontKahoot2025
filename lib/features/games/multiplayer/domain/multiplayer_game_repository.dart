import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';

abstract class IMultiplayerGameRepository {
  Stream<GameSession> get gameStream;

  //Conexiones
  Future<String> createGame(String quizId);
  Future<void> joinGame(String pin, String nickname);
  Future<void> connectToGame(
    String pin,
    String nickname,
    String jwt,
    GameRole role,
  );

  //Acciones del host/jugador
  Future<void> startGame(); // Host
  Future<void> nextPhase(); // Host
  Future<void> submitAnswer(
    String questionIndex,
    int answerIndex,
    int timeElapsedMs,
    String jwt,
  ); // Jugador

  void dispose();
}
