import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';

abstract class IMultiplayerGameRepository {
  Stream<GameSession> get gameStream;

  //Conexiones
  Future<void> createGame(String quizId);
  Future<void> joinGame(String pin, String nickname);

  //Acciones del host/jugador
  Future<void> startGame(); // Host
  Future<void> nextPhase(); // Host
  Future<void> submitAnswer(String questionIndex, String answerIndex); // Jugador
  
  void dispose();
}