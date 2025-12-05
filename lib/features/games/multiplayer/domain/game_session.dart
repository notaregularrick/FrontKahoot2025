import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/individual_scoreboard.dart';
import 'player.dart';

class GameSession {
  final String pin;
  final GameStatus status;

  //Lobby
  final String? quizTitle;
  final String? quizMediaUrl;

  //Estado de Jugadores
  final List<Player> players;
  final int playerCount;

  //Pregunta Actual
  final CurrentQuestion? currentQuestion;

  //Resultados
  final String? correctAnswerText;
  final int? correctAnswerIndex;
  final int? pointsEarned;
  final List<IndividualScoreboard>
  playerScoreboard; //sirve tanto aquí como en END

  //Fin de juego
  final String? winnerNickname;

  const GameSession({
    required this.pin,
    required this.status,
    this.quizTitle,
    this.quizMediaUrl,
    this.players = const [],
    this.playerCount = 0,
    this.currentQuestion,
    this.correctAnswerText,
    this.correctAnswerIndex,
    this.pointsEarned,
    this.playerScoreboard = const [],
    this.winnerNickname,
  });

  bool get isLobby => status == GameStatus.lobby;
  bool get isQuestionActive => status == GameStatus.question;
  bool get isResults => status == GameStatus.results;
  bool get isGameEnd => status == GameStatus.end;

  // Estado inicial vacío (antes de conectar)
  factory GameSession.initial() {
    return const GameSession(pin: '', status: GameStatus.connecting);
  }

  void orderScoreboardByRank() {
    if (playerScoreboard.isEmpty) return;
    playerScoreboard.sort((a, b) => a.rank.compareTo(b.rank));
  }

  String answerTextByIndex(int index) {
    if (currentQuestion == null) return '';
    return currentQuestion!.getAnswerTextByIndex(index);
  }

  int getPlayerScoreById(String playerId) {
    for (var entry in playerScoreboard) {
      if (entry.playerId == playerId || entry.nickname == playerId) {
        return entry.score;
      }
    }
    return 0;
  }

  int getPlayerRankById(String playerId) {
    for (var entry in playerScoreboard) {
      if (entry.playerId == playerId || entry.nickname == playerId) {
        return entry.rank;
      }
    }
    return 0;
  }

  GameSession copyWith({
    String? pin,
    GameStatus? status,
    String? quizTitle,
    String? quizMediaUrl,
    List<Player>? players,
    int? playerCount,
    CurrentQuestion? currentQuestion,
    int? correctAnswerIndex,
    String? correctAnswerText,
    int? pointsEarned,
    List<IndividualScoreboard>? playerScoreboard,
    String? winnerNickname,
  }) {
    return GameSession(
      pin: pin ?? this.pin,
      status: status ?? this.status,
      quizTitle: quizTitle ?? this.quizTitle,
      quizMediaUrl: quizMediaUrl ?? this.quizMediaUrl,
      players: players ?? this.players,
      playerCount: playerCount ?? this.playerCount,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      correctAnswerText: correctAnswerText ?? this.correctAnswerText,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      playerScoreboard: playerScoreboard ?? this.playerScoreboard,
      winnerNickname: winnerNickname ?? this.winnerNickname,
    );
  }
}
