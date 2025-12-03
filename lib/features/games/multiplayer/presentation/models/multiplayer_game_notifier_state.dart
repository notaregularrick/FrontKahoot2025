
import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';

class GameNotifierState {
  //DATOS DEL SERVIDOR
  final GameSession session;

  //CONTEXTO LOCAL
  final GameRole role;             
  final String? myPlayerId;    //TENTATIVO    

  //ESTADO DE UI
  final bool hasAnsweredCurrentQuestion; //Bloquear botones
  //final bool isLoadingAction;         // Para mostrar spinner en botones al enviar
  //final String? errorMessage;         // Para mostrar SnackBars de error temporalmente

  const GameNotifierState({
    required this.session,
    this.role = GameRole.player,
    this.myPlayerId,
    this.hasAnsweredCurrentQuestion = false,
  });

  //GETTERS DE PRESENTACIÓN

  bool get isHost => role == GameRole.host;

  bool get isLobby => session.status == GameStatus.lobby;
  bool get isQuestionActive => session.status == GameStatus.question;
  bool get isResults => session.status == GameStatus.results;
  bool get isGameEnd => session.status == GameStatus.end;

  //COPY WITH
  GameNotifierState copyWith({
    GameSession? session,
    GameRole? role,
    String? myPlayerId,
    bool? hasAnsweredCurrentQuestion,
    bool? isLoadingAction,
    String? errorMessage,
  }) {
    return GameNotifierState(
      session: session ?? this.session,
      role: role ?? this.role,
      myPlayerId: myPlayerId ?? this.myPlayerId,
      hasAnsweredCurrentQuestion: hasAnsweredCurrentQuestion ?? this.hasAnsweredCurrentQuestion,
    );
  }
}