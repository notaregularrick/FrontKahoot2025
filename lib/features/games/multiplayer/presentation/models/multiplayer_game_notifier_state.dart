import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_session.dart';

class GameNotifierState {
  final MultiplayerGameSession session;
  final String quizTitle;
  final String quizImageUrl;

  final GameRole role;
  final String? myPlayerId; 

  final bool hasAnsweredCurrentQuestion;
  final bool isLoading;
  final String? errorMessage;

  const GameNotifierState({
    required this.session,
    this.role = GameRole.player,
    this.myPlayerId,
    this.hasAnsweredCurrentQuestion = false,
    this.isLoading = false,
    this.errorMessage,
    this.quizTitle = "",
    this.quizImageUrl = "",
  });

  bool get isHost => role == GameRole.host;

  int get myScore {
    if(role != GameRole.player) {
      return 0;
    }
    if (session.playerGameEnd != null) {
      return session.playerGameEnd!.totalScore;
    }
    if (session.playerResults != null) {
      return session.playerResults!.totalScore;
    }
    return 0; 
  }

  int get myRank {
    if(role != GameRole.player) {
      return 0;
    }
    if (session.playerGameEnd != null) {
      return session.playerGameEnd!.rank;
    }
    if (session.playerResults != null) {
      return session.playerResults!.rank;
    }
    return 0;
  }

  bool get isLobby => session.isLobby;
  bool get isQuestionActive => session.isQuestionActive;
  bool get isResults => session.isResults;
  bool get isGameEnd => session.isGameEnd;

  // COPY WITH
  GameNotifierState copyWith({
    MultiplayerGameSession? session,
    String? quizTitle,
    String? quizImageUrl,
    GameRole? role,
    String? myPlayerId,
    bool? hasAnsweredCurrentQuestion,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GameNotifierState(
      session: session ?? this.session,
      quizTitle: quizTitle ?? this.quizTitle,
      quizImageUrl: quizImageUrl ?? this.quizImageUrl,
      role: role ?? this.role,
      myPlayerId: myPlayerId ?? this.myPlayerId,
      hasAnsweredCurrentQuestion:
          hasAnsweredCurrentQuestion ?? this.hasAnsweredCurrentQuestion,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}