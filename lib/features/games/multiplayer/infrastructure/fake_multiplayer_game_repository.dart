import 'dart:async';

import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/individual_scoreboard.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player.dart';

class FakeGameRepositoryImpl implements IMultiplayerGameRepository {
  // 1. El "Tubo" del Stream
  final _controller = StreamController<GameSession>.broadcast();

  // 2. Memoria local para fusionar estados
  GameSession _currentSession = GameSession.initial();

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
        newSession = _currentSession.copyWith(status: GameStatus.end);
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

      // Paso B: Extraemos metadatos del Envoltorio
      // int qIndex = (outerSlideData['questionIndex'] as num?)?.toInt() ?? 0;
      // int tLimit = (outerSlideData['timeLimitSeconds'] as num?)?.toInt() ?? 20;

      // // Paso C: Obtenemos el objeto "Contenido" (Inner)
      // final innerSlideContent = outerSlideData['currentSlideData'];

      // if (innerSlideContent != null &&
      //     innerSlideContent is Map<String, dynamic>) {
      //   final List<dynamic> rawAnswers =
      //       innerSlideContent['options'] as List<dynamic>? ?? [];

      //   List<QuestionAnswers> optionsList = rawAnswers.asMap().entries.map((
      //     entry,
      //   ) {
      //     final int idx = entry.key;
      //     final answerData = entry.value as Map<String, dynamic>;

      //     return QuestionAnswers(
      //       answerIndex: idx,
      //       answerText: answerData['text'] ?? '',
      //       answerImageUrl: answerData['image'],
      //     );
      //   }).toList();

      //   // Paso D: Construimos la entidad final mezclando ambos niveles
      //   currentQuestion = CurrentQuestion(
      //     // Datos del Inner (Contenido)
      //     questionId: innerSlideContent['slideId'] ?? '',
      //     questionText: innerSlideContent['questionText'] ?? '',
      //     questionImageUrl: innerSlideContent['mediaUrl'],
      //     type: innerSlideContent['type'] ?? 'MULTIPLE_CHOICE',

      //     // Datos del Outer (Lógica de la partida)
      //     questionIndex: qIndex,
      //     timeLimitSeconds: tLimit,

      //     // Opciones (Dentro del Inner)
      //     options: optionsList,
      //   );
      // }
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
      playerScoreboard: [],
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

  @override
  Future<void> joinGame(String pin, String nickname) async {
    // Simulamos delay de red
    await Future.delayed(const Duration(seconds: 1));
    _currentSession = _currentSession.copyWith(pin: pin);
    // 1. Emitimos estado inicial (LOBBY)
    _handleIncomingEvent('game_state_update', {
      "state": "LOBBY",
      "quizTitle": "Flutter Básico",
      "players": [
        {"nickname": "Profe", "score": 0},
        {"nickname": nickname, "score": 0}, // Tú
      ],
    });

    // 2. INICIAR GUION AUTOMÁTICO (Solo para probar)
    // En 3 segundos, el "profe" iniciará el juego
    //Future.delayed(const Duration(seconds: 3), _runScript);
  }

  //GameSession processQuestionStartedData(Map<String, dynamic> data) {}

  void _runScript() async {
    // --- PREGUNTA 1 ---
    _handleIncomingEvent('question_started', {
      "questionIndex": 1,
      "timeLimit": 10,
      "currentSlideData": {
        "id": "q1",
        "questionText": "¿Qué widget se usa para layouts verticales?",
        "options": [
          {"id": "0", "text": "Row"},
          {"id": "1", "text": "Column"},
          {"id": "2", "text": "Stack"},
          {"id": "3", "text": "ListView"},
        ],
      },
    });

    await Future.delayed(const Duration(seconds: 6));

    // --- RESULTADOS 1 ---
    _handleIncomingEvent('question_results', {
      "correctAnswerIndex": 1,
      "pointsEarned": 950,
      "playerScoreboard": [
        {"nickname": "Yo", "score": 950, "rank": 1},
      ],
    });

    await Future.delayed(const Duration(seconds: 4));

    // --- FIN DEL JUEGO ---
    _handleIncomingEvent('game_end', {
      "winnerNickname": "Yo",
      "finalScoreboard": [
        {"nickname": "Yo", "score": 950, "rank": 1},
      ],
    });
  }

  @override
  Future<void> submitAnswer(String questionId, int answerIndex, int timeElapsedMs, String jwt) async {
    print("FakeRepo: Enviando respuesta $answerIndex");
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
}

void main() {
  final fakeRepo = FakeGameRepositoryImpl();

  // final Map<String, dynamic> mockLobbyData = {
  //   "hostId": "host-uuid-123",
  //   "state": "LOBBY",
  //   "quizTitle": "Cultura General 2025",
  //   "quizMediaUrl": "https://placehold.co/600x400/png?text=Intro",
  //   "players": [
  //     {
  //       "playerId": "p-001",
  //       "nickname": "Jorge",
  //       "avatarUrl": "https://i.pravatar.cc/150?u=Jorge",
  //     },
  //     {"playerId": "p-002", "nickname": "Maria", "avatarUrl": null},
  //   ],
  //   // En lobby, currentSlideData suele ser null o vacío
  //   "currentSlideData": null,
  // };

  final Map<String, dynamic> mockLobbyData = {
    "hostId": "host-uuid-123",
    "state": "LOBBY",
    // Información del Quiz que se va a jugar
    "quizTitle": "Capitales de Europa",
    "quizMediaUrl": "https://placehold.co/600x400/blue/white.png?text=Europa",

    // Lista inicial de jugadores conectados
    "players": [
      {
        "playerId": "p-001",
        "nickname": "Jorge", // El usuario actual
      },
      {"playerId": "p-002", "nickname": "Maria"},
    ],

    // En el Lobby aún no hay pregunta activa
    "currentSlideData": null,
  };

  final Map<String, dynamic> mockQuestionStartedData = {
    // 1. Datos Lógicos (Raíz)
    "questionIndex": 3,
    "timeLimitSeconds": 15,

    // 2. Datos de Contenido (Anidados)
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

  final Map<String, dynamic> mockResultsData = {
    // El ID 1 coincide con "París" en tu lista de opciones anterior
    "correctAnswerIndex": 1,

    // Puntos que ganó el usuario (Tú)
    "pointsEarned": 850,

    // Lista de jugadores actualizada
    "playerScoreboard": [
      {
        "playerId": "p-001",
        "nickname": "Jorge",
        "score": 850, // Puntaje total
        "rank": 1, // Vas ganando
        "previousRank": 1,
      },
      {
        "playerId": "p-002",
        "nickname": "Maria",
        "score": 0,
        "rank": 2,
        "previousRank": 2,
      },
    ],
  };

  // final Map<String, dynamic> mockQuestionData = {
  //   "hostId": "host-uuid-123",
  //   "state": "QUESTION",
  //   "quizTitle": "Geografía Europea",
  //   "quizMediaUrl": null,
  //   "players": [
  //     {"nickname": "Jorge", "score": 100},
  //     {"nickname": "Maria", "score": 200},
  //   ],
  //   // ESTRUCTURA DE DOBLE ANIDACIÓN
  //   "currentSlideData": {
  //     // Outer: Metadatos Lógicos
  //     "questionIndex": 3,
  //     "timeLimitSeconds": 30,
  //     // Inner: Contenido Visual
  //     "currentSlideData": {
  //       "slideId": "slide-uuid-777",
  //       "questionText": "¿Cuál es la capital de Italia?",
  //       "mediaUrl": "https://placehold.co/600x400/green/white.png?text=Italia",
  //       "type": "MULTIPLE_CHOICE",
  //       "options": [
  //         {"text": "Venecia", "image": null},
  //         {"text": "Roma", "image": null}, // Debería ser índice 1
  //         {"text": "Milán", "image": null},
  //         {"text": "Nápoles", "image": null},
  //       ],
  //     },
  //   },
  // };

  final Map<String, dynamic> mockGameEndData = {
    "winnerNickname": "Jorge",

    "finalScoreboard": [
      {
        "playerId": "p-001",
        "nickname": "Jorge",
        "score": 850,
        "rank": 1,
        "correctCount": 1, // 1 acierto (La de Francia)
        "incorrectCount": 0,
      },
      {
        "playerId": "p-002",
        "nickname": "Maria",
        "score": 0,
        "rank": 2,
        "correctCount": 0,
        "incorrectCount": 1, // Falló la pregunta
      },
    ],
  };

  print('🚀 PROCESANDO DATOS SIMULADOS...');
  fakeRepo._handleIncomingEvent('game_state_update', mockLobbyData);
  fakeRepo.printDetailedGameSession(fakeRepo._currentSession);
  fakeRepo._handleIncomingEvent('question_started', mockQuestionStartedData);
  fakeRepo.printDetailedGameSession(fakeRepo._currentSession);
  fakeRepo._handleIncomingEvent('question_results', mockResultsData);
  fakeRepo.printDetailedGameSession(fakeRepo._currentSession);
  fakeRepo._handleIncomingEvent('game_end', mockGameEndData);
  fakeRepo.printDetailedGameSession(fakeRepo._currentSession);
}
