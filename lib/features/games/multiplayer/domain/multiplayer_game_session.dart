import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player_game_end.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player_results.dart';

class MultiplayerGameSession {
  final String pin;
  final String id;
  final String nickname;
  final CurrentQuestion? currentQuestion;

  final GameStatus gameStatus;
  final ConnectionStatus connectionStatus;

  final PlayerGameEnd? playerGameEnd;
  final PlayerResults? playerResults;

  const MultiplayerGameSession({
    this.pin='',
    this.id = '',
    this.nickname = 'host',
    this.currentQuestion,
    this.gameStatus = GameStatus.none,
    this.connectionStatus = ConnectionStatus.connecting,
    this.playerGameEnd,
    this.playerResults,
  });
  
  MultiplayerGameSession copyWith({
    String? pin,
    String? id,
    String? nickname,
    CurrentQuestion? currentQuestion,
    GameStatus? gameStatus,
    ConnectionStatus? connectionStatus,
    PlayerGameEnd? playerGameEnd,
    PlayerResults? playerResults,
  }) {
    return MultiplayerGameSession(
      pin: pin ?? this.pin,
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      gameStatus: gameStatus ?? this.gameStatus,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      playerGameEnd: playerGameEnd ?? this.playerGameEnd,
      playerResults: playerResults ?? this.playerResults,
    );
  }

  bool get isLobby => gameStatus == GameStatus.lobby;
  bool get isQuestionActive => gameStatus == GameStatus.question;
  bool get isResults => gameStatus == GameStatus.results;
  bool get isGameEnd => gameStatus == GameStatus.end;
}
