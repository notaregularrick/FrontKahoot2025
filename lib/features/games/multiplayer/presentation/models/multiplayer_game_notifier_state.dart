
import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';

class GameNotifierState {
  //DATOS DEL SERVIDOR
  final GameSession session;

  //CONTEXTO LOCAL
  final GameRole role;             
  final String? myPlayerId;  

  //ESTADO DE UI
  final bool hasAnsweredCurrentQuestion; //Bloquear botones
  final bool isLoading;
  final String? errorMessage;

  const GameNotifierState({
    required this.session,
    this.role = GameRole.player,
    this.myPlayerId,
    this.hasAnsweredCurrentQuestion = false,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isHost => role == GameRole.host;

  int get myScore{
    if (myPlayerId == null) return 0;
    return session.getPlayerScoreById(  myPlayerId!);
  }
  int get myRank{
    if (myPlayerId == null) return 0;
    return session.getPlayerRankById(  myPlayerId!);
  }

  bool get isLobby => session.isLobby;
  bool get isQuestionActive => session.isQuestionActive;
  bool get isResults => session.isResults;
  bool get isGameEnd => session.isGameEnd;

  //COPY WITH
  GameNotifierState copyWith({
    GameSession? session,
    GameRole? role,
    String? myPlayerId,
    bool? hasAnsweredCurrentQuestion,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GameNotifierState(
      session: session ?? this.session,
      role: role ?? this.role,
      myPlayerId: myPlayerId ?? this.myPlayerId,
      hasAnsweredCurrentQuestion: hasAnsweredCurrentQuestion ?? this.hasAnsweredCurrentQuestion,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}