import 'dart:async';

import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/individual_scoreboard.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player.dart';

class FakeGameRepositoryImpl implements IMultiplayerGameRepository {
  final _controller = StreamController<GameSession>.broadcast();

  //Para fusionar las sesiones (estado)
  GameSession _currentSession = GameSession.initial();

  String myNickname = "Diego"; //YA
  int myAnswerIndex = 1;
  int pointsEarned = 0;
  int myTotalScore = 0;
  int myRank = 1;
  int otherRank1 = 1;
  int otherRank2 = 2;
  int otherRank3 = 3;
  String winner = "Maria";
  int myCorrectCount = 0;
  int myIncorrectCount = 0;

  //MOCK DATA

  Map<String, dynamic> get mockLobbyData => {
    "hostId": "host-uuid-123",
    "state": "LOBBY",
    // Información del Quiz que se va a jugar
    "quizTitle": "Capitales de Europa",
    "quizMediaUrl": "https://placehold.co/600x400/blue/white.png?text=Europa",

    // Lista inicial de jugadores conectados
    "players": [
      {
        "playerId": "p-001",
        "nickname": myNickname, // El usuario actual
      },
      {"playerId": "p-002", "nickname": "Maria"},
      {"playerId": "p-003", "nickname": "Carlos"},
      {"playerId": "p-004", "nickname": "Andrea"},
    ],

    // En el Lobby aún no hay pregunta activa
    "currentSlideData": null,
  };

  Map<String, dynamic> get mockQuestionStartedData => {
    // 1. Datos Lógicos (Raíz)
    "questionIndex": 1,
    "timeLimitSeconds": 10,

    "currentSlideData": {
      "slideId": "slide-uuid-999",
      "questionText": "¿Cuál es la capital de Francia?",
      "mediaUrl": "https://placehold.co/600x400/blue/white.png?text=Francia",
      "type": "MULTIPLE_CHOICE",
      "options": [
        {"text": "Madrid", "image": null},
        {"text": "París", "image": null},
        {"text": "Londres", "image": null},
        {"text": "Berlín", "image": null},
      ],
    },
  };

  Map<String, dynamic> get mockResultsData => {
    "correctAnswerIndex": 1,

    // Puntos que ganó el usuario (Tú)
    "pointsEarned": pointsEarned,

    // Lista de jugadores actualizada
    "playerScoreboard": [
      {
        "playerId": "p-001",
        "nickname": myNickname,
        "score": myTotalScore,
        "rank": myRank,
        "previousRank": 0,
      },
      {
        "playerId": "p-002",
        "nickname": "Maria",
        "score": 500,
        "rank": otherRank1,
        "previousRank": 0,
      },
      {
        "playerId": "p-003",
        "nickname": "Carlos",
        "score": 100,
        "rank": otherRank2,
        "previousRank": 0,
      },
      {
        "playerId": "p-004",
        "nickname": "Andrea",
        "score": 50,
        "rank": otherRank3,
        "previousRank": 0,
      },
    ],
  };

  Map<String, dynamic> get mockGameEndData => {
    "winnerNickname": winner,

    "finalScoreboard": [
      {
        "playerId": "p-001",
        "nickname": myNickname,
        "score": myTotalScore,
        "rank": myRank,
        "correctCount": myCorrectCount,
        "incorrectCount": myIncorrectCount,
      },
      {
        "playerId": "p-002",
        "nickname": "Maria",
        "score": 500,
        "rank": otherRank1,
        "correctCount": 1,
        "incorrectCount": 0,
      },
      {
        "playerId": "p-003",
        "nickname": "Carlos",
        "score": 100,
        "rank": otherRank2,
        "correctCount": 1,
        "incorrectCount": 0,
      },
      {
        "playerId": "p-004",
        "nickname": "Andrea",
        "score": 50,
        "rank": otherRank3,
        "correctCount": 1,
        "incorrectCount": 0,
      },
    ],
  };

  @override
  Stream<GameSession> get gameStream => _controller.stream;

  @override
  Future<void> connectToGame(
    String pin,
    String nickname,
    String jwt,
    GameRole role,
  ) async {
    //delay de red
    await Future.delayed(const Duration(seconds: 1));
    joinGame(pin, nickname);
  }

  // --- Menajdor de los eventos ---
  void _handleIncomingEvent(String eventName, Map<String, dynamic> payload) {
    GameSession newSession = _currentSession;

    switch (eventName) {
      case 'game_state_update':
        //newSession = GameSessionDto.fromJson(payload);
        //newSession = _currentSession.copyWith(status: GameStatus.lobby);
        newSession = _processGameStateUpdateData(payload);
        break;

      case 'player_join':
        // Agregamos un jugador a la lista existente

        // final newPlayer = PlayerDto.fromJson(payload);
        // newSession = _currentSession.copyWith(
        //   players: [..._currentSession.players, newPlayer],
        //   playerCount: _currentSession.playerCount + 1,
        // );
        newSession = _currentSession.copyWith(status: GameStatus.lobby);
        break;

      case 'question_started':
        if (payload.isNotEmpty) {
          newSession = _processQuestionStartedData(payload);
        }
        break;

      case 'question_results':
        newSession = _processQuestionResultsData(payload);
        break;

      case 'game_end':
        // Cambiamos a modo FIN

        // final finalScores = (payload['finalScoreboard'] as List)
        //     .map((e) => ScoreboardEntryDto.fromJson(e))
        //     .toList();

        // newSession = _currentSession.copyWith(
        //   status: GameStatus.end,
        //   leaderboard: finalScores,
        //   winnerNickname: payload['winnerNickname'],
        // );
        newSession = _processGameEndData(payload);
        break;
    }

    _currentSession = newSession;
    _controller.add(newSession);
  }

  CurrentQuestion? _parseCurrentQuestion(Map<String, dynamic> questionData) {
    int qIndex = (questionData['questionIndex'] as num?)?.toInt() ?? 0;
    int tLimit = (questionData['timeLimitSeconds'] as num?)?.toInt() ?? 20;

    // Paso C: Obtenemos el objeto "Contenido" (Inner)
    final questionInfo = questionData['currentSlideData'];

    if (questionInfo != null && questionInfo is Map<String, dynamic>) {
      final List<dynamic> rawAnswers =
          questionInfo['options'] as List<dynamic>? ?? [];

      List<QuestionAnswers> optionsList = rawAnswers.asMap().entries.map((
        entry,
      ) {
        final int idx = entry.key;
        final answerData = entry.value as Map<String, dynamic>;

        return QuestionAnswers(
          answerIndex: idx,
          answerText: answerData['text'] ?? '',
          answerImageUrl: answerData['image'],
        );
      }).toList();

      // Paso D: Construimos la entidad final mezclando ambos niveles
      return CurrentQuestion(
        // Datos del Inner (Contenido)
        questionId: questionInfo['slideId'] ?? '',
        questionText: questionInfo['questionText'] ?? '',
        questionImageUrl: questionInfo['mediaUrl'],
        type: questionInfo['type'] ?? 'MULTIPLE_CHOICE',

        // Datos del Outer (Lógica de la partida)
        questionIndex: qIndex,
        timeLimitSeconds: tLimit,

        // Opciones (Dentro del Inner)
        options: optionsList,
      );
    }
    return null;
  }

  Player _parsePlayer(Map<String, dynamic> data) {
    return Player(
      playerId: data['playerId'] ?? 'unknown',
      nickname: data['nickname'] ?? 'Anónimo',
    );
  }

  // Este método sirve tanto para 'playerScoreboard' (Parcial) como para 'finalScoreboard' (Final)
  IndividualScoreboard _parseScoreboard(Map<String, dynamic> json) {
    return IndividualScoreboard(
      playerId: json['playerId'] ?? '',
      nickname: json['nickname'] ?? 'Anónimo',
      score: (json['score'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,

      //question_result
      previousRank: (json['previousRank'] as num?)?.toInt(),

      //game_end
      correctCount: (json['correctCount'] as num?)?.toInt(),
      incorrectCount: (json['incorrectCount'] as num?)?.toInt(),
    );
  }

  GameSession _processGameStateUpdateData(Map<String, dynamic> data) {
    //Parseo de datos básicos (Raíz)
    String pin = _currentSession.pin;

    // Mapeo del estado
    String stateStr = data['state'] as String? ?? 'LOBBY';
    GameStatus status;
    switch (stateStr) {
      case 'QUESTION':
        status = GameStatus.question;
        break;
      case 'RESULTS':
        status = GameStatus.results;
        break;
      case 'END':
        status = GameStatus.end;
        break;
      default:
        status = GameStatus.lobby;
    }

    // 2. Parseo de Jugadores
    List<dynamic> playersData = data['players'] as List<dynamic>? ?? [];
    List<Player> players = playersData.map((playerMap) {
      return _parsePlayer(playerMap as Map<String, dynamic>);
    }).toList();

    // 3. Parseo de la Pregunta (DOBLE ANIDACIÓN)
    CurrentQuestion? currentQuestion;

    // Paso A: Obtenemos el objeto "Envoltorio" (Outer)
    final outerSlideData = data['currentSlideData'];

    if (outerSlideData != null && outerSlideData is Map<String, dynamic>) {
      currentQuestion = _parseCurrentQuestion(outerSlideData);
    }

    // 4. Retorno de la Sesión
    return GameSession(
      pin: pin,
      status: status,

      quizTitle: data['quizTitle'],
      quizMediaUrl: data['quizMediaUrl'],

      players: players,
      playerCount: players.length,

      currentQuestion: currentQuestion,

      correctAnswerIndex: (data['correctAnswerIndex'] as num?)?.toInt(),
      pointsEarned: (data['pointsEarned'] as num?)?.toInt(),
      winnerNickname: data['winnerNickname'],
    );
  }

  GameSession _processQuestionStartedData(Map<String, dynamic> data) {
    CurrentQuestion? question = _parseCurrentQuestion(data);
    return _currentSession.copyWith(
      status: GameStatus.question,
      currentQuestion: question,
      correctAnswerIndex: null,
      correctAnswerText: null,
      pointsEarned: null,
    );
  }

  GameSession _processQuestionResultsData(Map<String, dynamic> data) {
    List<dynamic> scoreboardData =
        data['playerScoreboard'] as List<dynamic>? ?? [];
    List<IndividualScoreboard> scoreboard = scoreboardData.map((entry) {
      return _parseScoreboard(entry as Map<String, dynamic>);
    }).toList();

    int? correctAnswerIndex = (data['correctAnswerIndex'] as num?)?.toInt();
    String? correctAnswerText = _currentSession.answerTextByIndex(
      correctAnswerIndex!,
    );

    return _currentSession.copyWith(
      status: GameStatus.results,
      correctAnswerIndex: correctAnswerIndex,
      correctAnswerText: correctAnswerText,
      pointsEarned: (data['pointsEarned'] as num?)?.toInt(),
      playerScoreboard: scoreboard,
    );
  }

  GameSession _processGameEndData(Map<String, dynamic> data) {
    List<dynamic> scoreboardData =
        data['finalScoreboard'] as List<dynamic>? ?? [];
    List<IndividualScoreboard> scoreboard = scoreboardData.map((entry) {
      return _parseScoreboard(entry as Map<String, dynamic>);
    }).toList();

    return _currentSession.copyWith(
      status: GameStatus.end,
      playerScoreboard: scoreboard,
      winnerNickname: data['winnerNickname'] as String?,
    );
  }

  @override
  Future<void> joinGame(String pin, String nickname) async {
    _currentSession = _currentSession.copyWith(pin: pin);
    myNickname = nickname;
    runPlayerScript();
  }

  // void _runScript() async {
  //   // --- PREGUNTA 1 ---
  //   _handleIncomingEvent('question_started', {
  //     "questionIndex": 1,
  //     "timeLimit": 10,
  //     "currentSlideData": {
  //       "id": "q1",
  //       "questionText": "¿Qué widget se usa para layouts verticales?",
  //       "options": [
  //         {"id": "0", "text": "Row"},
  //         {"id": "1", "text": "Column"},
  //         {"id": "2", "text": "Stack"},
  //         {"id": "3", "text": "ListView"},
  //       ],
  //     },
  //   });
  //   await Future.delayed(const Duration(seconds: 6));
  //   // --- RESULTADOS 1 ---
  //   _handleIncomingEvent('question_results', {
  //     "correctAnswerIndex": 1,
  //     "pointsEarned": 950,
  //     "playerScoreboard": [
  //       {"nickname": "Yo", "score": 950, "rank": 1},
  //     ],
  //   });
  //   await Future.delayed(const Duration(seconds: 4));
  //   // --- FIN DEL JUEGO ---
  //   _handleIncomingEvent('game_end', {
  //     "winnerNickname": "Yo",
  //     "finalScoreboard": [
  //       {"nickname": "Yo", "score": 950, "rank": 1},
  //     ],
  //   });
  // }

  @override
  Future<void> submitAnswer(
    String questionId,
    int answerIndex,
    int timeElapsedMs,
    String jwt,
  ) async {
    myAnswerIndex = answerIndex;
    if (answerIndex == 1) {
      pointsEarned = 1000;
      myTotalScore += pointsEarned;
      myCorrectCount += 1;
      myRank = 1;

      otherRank1 = 2;
      otherRank2 = 3;
      otherRank3 = 4;
    } else {
      pointsEarned = 0;
      myTotalScore += pointsEarned;
      myIncorrectCount += 1;
      myRank = 4;

      otherRank1 = 1;
      otherRank2 = 2;
      otherRank3 = 3;
    }
  }

  @override
  Future<String> createGame(String kahootId) async {
    return '';
  }

  @override
  Future<void> startGame() async {}
  @override
  Future<void> nextPhase() async {}

  @override
  void dispose() {
    _controller.close();
  }

  void printDetailedGameSession(GameSession session) {
    print('\n╔══════════════════════════════════════════════════════════════╗');
    print('║                 ESTADO DE LA SESIÓN DE JUEGO                 ║');
    print('╚══════════════════════════════════════════════════════════════╝');

    // --- 1. DATOS GENERALES ---
    print('🔹 [GENERAL]');
    print('   • Estado (Status):    ${session.status.name.toUpperCase()}');
    print('   • PIN de Sala:        "${session.pin}"');
    print('   • Título del Quiz:    ${session.quizTitle ?? "N/A"}');
    print('   • Imagen del Quiz:    ${session.quizMediaUrl ?? "N/A"}');
    print('   • Cant. Jugadores:    ${session.playerCount}');
    print('   • Ganador Final:      ${session.winnerNickname ?? "N/A"}');

    // --- 2. LISTA DE JUGADORES (LOBBY) ---
    print('\n🔹 [PLAYERS] (${session.players.length})');
    if (session.players.isEmpty) {
      print('   (Lista vacía)');
    } else {
      for (var i = 0; i < session.players.length; i++) {
        final p = session.players[i];
        print('   [$i] ${p.nickname} (ID: ${p.playerId})');
        if (p.avatarUrl != null) print('        Avatar: ${p.avatarUrl}');
      }
    }

    // --- 3. PREGUNTA ACTUAL (QUESTION) ---
    print('\n🔹 [CURRENT QUESTION]');
    final q = session.currentQuestion;
    if (q == null) {
      print('   (Nula / No activa)');
    } else {
      print('   • ID Pregunta:    ${q.questionId}');
      print('   • Índice:         ${q.questionIndex}');
      print('   • Tipo:           ${q.type}');
      print('   • Tiempo Límite:  ${q.timeLimitSeconds} seg');
      print('   • Texto:          "${q.questionText}"');
      print('   • Imagen URL:     ${q.questionImageUrl ?? "Ninguna"}');

      print('   --- Opciones (${q.options.length}) ---');
      if (q.options.isEmpty) {
        print('       (Sin opciones)');
      } else {
        for (var opt in q.options) {
          print(
            '       [${opt.answerIndex}] "${opt.answerText}" (Img: ${opt.answerImageUrl ?? "No"})',
          );
        }
      }
    }

    // --- 4. RESULTADOS DE LA RONDA (RESULTS) ---
    print('\n🔹 [RESULTS INFO]');
    print('   • Resp. Correcta (Idx):  ${session.correctAnswerIndex ?? "N/A"}');
    print('   • Resp. Correcta (Txt):  ${session.correctAnswerText ?? "N/A"}');
    print('   • Puntos Ganados (Yo):   ${session.pointsEarned ?? "N/A"}');

    // --- 5. SCOREBOARD / LEADERBOARD ---
    print('\n🔹 [SCOREBOARD] (${session.playerScoreboard.length})');
    if (session.playerScoreboard.isEmpty) {
      print('   (Vacío)');
    } else {
      for (var i = 0; i < session.playerScoreboard.length; i++) {
        final sb = session.playerScoreboard[i];
        print('   #${sb.rank} - ${sb.nickname} (${sb.score} pts)');
        print('       ID: ${sb.playerId}');
        print('       Rank: ${sb.rank}');
        if (sb.previousRank != null)
          print('       Prev Rank: ${sb.previousRank}');
        if (sb.correctCount != null)
          print('       Aciertos:  ${sb.correctCount}');
        if (sb.incorrectCount != null)
          print('       Fallos:    ${sb.incorrectCount}');
      }
    }
    print('════════════════════════════════════════════════════════════════\n');
  }

  void runPlayerScript() async {
    _handleIncomingEvent('game_state_update', mockLobbyData);
    await Future.delayed(const Duration(seconds: 5));
    printDetailedGameSession(_currentSession);
    _handleIncomingEvent('question_started', mockQuestionStartedData);
    printDetailedGameSession(_currentSession);
    await Future.delayed(const Duration(seconds: 10));
    _handleIncomingEvent('question_results', mockResultsData);
    printDetailedGameSession(_currentSession);
    await Future.delayed(const Duration(seconds: 5));
    _handleIncomingEvent('game_end', mockGameEndData);
    printDetailedGameSession(_currentSession);
  }
}

void main() {
  final fakeRepo = FakeGameRepositoryImpl();
  fakeRepo.joinGame("111111", "PEPE");
  fakeRepo.submitAnswer("questionId", 0, 1, "");
}
