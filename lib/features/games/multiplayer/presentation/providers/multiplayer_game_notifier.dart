import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/models/multiplayer_game_notifier_state.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/use_cases_providers.dart';

class MultiplayerGameNotifier
    extends AutoDisposeAsyncNotifier<GameNotifierState> {
  StreamSubscription<GameSession>? _gameSubscription;
  DateTime? _questionStartTime;

  @override
  FutureOr<GameNotifierState> build() {
    ref.onDispose(() {
      _gameSubscription?.cancel();
    });

    return GameNotifierState(
      session: GameSession.initial(),
      role: GameRole.none,
      myPlayerId: null,
    );
  }

  void _subscribeToGameStream() {
    final listenUseCase = ref.read(listenGameSessionUseCaseProvider);
    _gameSubscription?.cancel();
    _gameSubscription = listenUseCase.execute().listen(
      (newSessionData) {
        final currentState = state.value;
        if (currentState == null) return;

        bool resetAnswered = true;

        if (newSessionData.status == GameStatus.question) {
          final String? oldQId =
              currentState.session.currentQuestion?.questionId;
          final String? newQId = newSessionData.currentQuestion?.questionId;

          if (newQId != null && newQId != oldQId) {
            _questionStartTime = DateTime.now(); // Iniciamos cronómetro
            resetAnswered = false; // Desbloqueamos botones
          }
        }
        newSessionData.orderScoreboardByRank();
        //Actualizar estado
        state = AsyncValue.data(
          currentState.copyWith(
            session: newSessionData,
            hasAnsweredCurrentQuestion: resetAnswered,
            isLoading: false,
          ),
        );
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );
  }

  Future<void> joinGame(String pin, String nickname) async {
    state = const AsyncValue.loading();
    try {
      final initialState = GameNotifierState(
        session: GameSession.initial().copyWith(pin: pin),
        role: GameRole.player,
        myPlayerId: nickname,
      );
      state = AsyncValue.data(initialState);

      _subscribeToGameStream();

      final useCase = ref.read(joinGameUseCaseProvider);
      await useCase.execute(pin, nickname, GameRole.player);
    } catch (e, st) {
      _gameSubscription?.cancel();
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createGame(String quizId) async {
    state = const AsyncValue.loading();

    try {
      //Primero crea sala y se conecta al juego (no como jugador) pero aún no está suscrito a eventos
      final useCase = ref.read(
        createGameUseCaseProvider,
      ); //OJO actualizar porque esto es un post, no un evento y debo obtener la respuesta
      String pin = await useCase.execute(quizId);

      //Actualizo estado para el host
      state = AsyncValue.data(
        GameNotifierState(
          session: GameSession.initial().copyWith(pin: pin),
          role: GameRole.host,
          myPlayerId: "HOST", //Temporal
        ),
      );

      //Ahora sí escucha eventos
      _subscribeToGameStream();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitAnswer(int answerIndex) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Validamos que haya una pregunta activa
    if (currentState.isQuestionActive == false) return;

    // Calculamos tiempo transcurrido
    final questionFinishTime = DateTime.now();
    final timeElapsed = questionFinishTime
        .difference(_questionStartTime!)
        .inMilliseconds;

    state = AsyncValue.data(
      currentState.copyWith(hasAnsweredCurrentQuestion: true, isLoading: true),
    );

    try {
      final useCase = ref.read(submitAnswerUseCaseProvider);

      await useCase.execute(
        currentState.session.currentQuestion!,
        answerIndex,
        timeElapsed,
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          hasAnsweredCurrentQuestion: false, //si algo falla que vuelva a enviar
          isLoading: false,
        ),
      );
    }
  }

  Future<void> startGame() async {
    try {
      final useCase = ref.read(startGameUseCaseProvider);
      await useCase.execute();
    } catch (e) {
      //Posible snackbar del error
    }
  }

  Future<void> nextPhase() async {
    try {
      final useCase = ref.read(changeNextPhaseUseCaseProvider);
      await useCase.execute();
    } catch (e) {
      //Posible snackbar del error
    }
  }
}

//revisar
final multiplayerGameNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      MultiplayerGameNotifier,
      GameNotifierState
    >(() => MultiplayerGameNotifier());
