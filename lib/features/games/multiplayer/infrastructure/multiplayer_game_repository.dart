import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player_game_end.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player_results.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class MultiplayerGameRepositoryImpl implements IMultiplayerGameRepository {
  final _sessionController =
      StreamController<MultiplayerGameSession>.broadcast();
  MultiplayerGameSession _currentGameSession = MultiplayerGameSession();

  @override
  Stream<MultiplayerGameSession> get gameStream => _sessionController.stream;

  late io.Socket _socket;

  @override
  Future<void> connectToGame(
    String pin,
    String nickname,
    String jwt,
    GameRole role,
  ) async {
    final url = 'https://quizzy-backend-0wh2.onrender.com/multiplayer-sessions';

    // Configuración del Cliente Socket.IO
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            'jwt': jwt,
            'pin': pin,
            'role': role == GameRole.host ? 'HOST' : 'PLAYER',
          })
          .build(),
    );

    // Eventos de conexión física
    _socket.onConnect((_) {
      debugPrint('✅ Socket Conectado (ID: ${_socket.id})');
      // _socket.emit('client_ready');
      // _socket.emit('player_join', {"nickname": nickname});
      _socket.emit('client_ready');
    });

    _socket.onConnectError((data) => debugPrint(' Error de conexión: $data'));

    _socket.onDisconnect((reason) {
      debugPrint('🔌 Desconectado. Razón: $reason');
    });

    //Listeners de eventos del juego:
    _socket.on('player_connected_to_server', (data) {
      _handleEvent('player_connected_to_server', data);
      _socket.emit('player_join', {"nickname": nickname});
    });

    _socket.on('player_connected_to_session', (data) {
      _handleEvent('player_connected_to_session', data);
    });

    _socket.on('question_started', (data) {
      _handleEvent('question_started', data);
    });

    _socket.on('player_answer_confirmation', (data) {
      _handleEvent('player_answer_confirmation', data);
    });

    _socket.on('player_results', (data) {
      _handleEvent('player_results', data);
    });

    _socket.on('player_game_end', (data) {
      _handleEvent('player_game_end', data);
    });

    _socket.on('session_closed', (data) {
      _handleEvent('session_closed', data);
    });

    //HOST
    _socket.on('host_results', (data) {
      _handleEvent('host_results', data);
    });

    _socket.connect();
  }

  // void notifyClientReady() {
  //   // Verificamos si _socket ha sido inicializada y si está conectada
  //   try {
  //     if (_socket.connected) {
  //       debugPrint('📤 [MANUAL] Enviando: client_ready');
  //       // _socket.emit('client_ready');
  //       // _socket.emit('player_join', {"nickname": "TestPlayer"});
  //     } else {
  //       debugPrint(
  //         '⚠️ No se pudo enviar client_ready: El socket no está conectado.',
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Error al intentar emitir: $e');
  //   }
  // }

  //EVENT HANDLER
  void _handleEvent(String eventName, dynamic payload) {
    debugPrint('\n📥 [EVENTO] $eventName');
    MultiplayerGameSession updatedSession = _currentGameSession;
    // Validación básica
    if (payload is! Map) {
      return;
    }

    final data = Map<String, dynamic>.from(payload);

    switch (eventName) {
      case 'player_connected_to_server':
        // {"status":"CONNECTED TO SERVER"}
        debugPrint('   🔹 Status: ${data['status']}');
        updatedSession = updatedSession.copyWith(
          connectionStatus: ConnectionStatus.connected,
        );
        break;

      case 'player_connected_to_session':
        // {"state":"lobby","nickname":"Carlitos","score":0,"connectedBefore":false}
        debugPrint('   🔹 Estado: ${data['state']}');
        debugPrint('   🔹 Nickname: ${data['nickname']}');
        debugPrint('   🔹 Score Inicial: ${data['score']}');
        updatedSession = updatedSession.copyWith(
          gameStatus: GameStatus.lobby,
          connectionStatus: ConnectionStatus.connected,
        ); //pantalla de espera
        break;

      case 'question_started':
        // Data compleja con "currentSlideData"
        // final slide = data['currentSlideData'];
        // debugPrint('   🔹 Estado: ${data['state']}');

        // if (slide != null) {
        //   debugPrint('   ❓ Pregunta: "${slide['questionText']}"');
        //   debugPrint('   ⏱️ Tiempo: ${slide['timeLimitSeconds']}s');
        //   debugPrint('   🖼️ Imagen: ${slide['slideImageURL'] ?? "Sin imagen"}');

        //   final options = slide['options'] as List?;
        //   if (options != null) {
        //     debugPrint('   🔠 Opciones (${options.length}):');
        //     for (var opt in options) {
        //       debugPrint('      - [${opt['index']}] ${opt['text'] ?? "Imagen: ${opt['mediaURL']}"}');
        //     }
        //   }
        // }
        CurrentQuestion question = CurrentQuestion.fromJson(
          data['currentSlideData'] as Map<String, dynamic>,
        );
        question.logDebugInfo();

        updatedSession = updatedSession.copyWith(
          gameStatus: GameStatus.question,
          currentQuestion: question,
          playerResults: null,
          playerGameEnd: null,
        );
        break;

      case 'player_answer_confirmation':
        // {"status":"ANSWER SUCCESFULLY SUBMITTED"}
        debugPrint('   ✅ Status: ${data['status']}');
        updatedSession = updatedSession.copyWith(
          gameStatus: GameStatus.answerSubmitted,
        );
        break;

      case 'player_results':
        // {"state":"results","isCorrect":true,"pointsEarned":932...}
        // final isCorrect = data['isCorrect'] == true;
        // debugPrint('   🔹 Resultado: ${isCorrect ? "¡CORRECTO! 🎉" : "Incorrecto ❌"}');
        // debugPrint('   🔹 Puntos ganados: ${data['pointsEarned']}');
        // debugPrint('   🔹 Racha: ${data['streak']} 🔥');
        // debugPrint('   🔹 Ranking actual: #${data['rank']}');
        // debugPrint('   🔹 Mensaje: "${data['message']}"');

        // // Accediendo al objeto anidado "progress"
        // if (data['progress'] != null) {
        //   debugPrint('   📊 Progreso: ${data['progress']['current']}/${data['progress']['total']}');
        // }
        PlayerResults results = PlayerResults.fromJson(data);
        results.logDebugInfo();

        updatedSession = updatedSession.copyWith(
          gameStatus: GameStatus.results,
          playerResults: results,
        );
        break;

      case 'player_game_end':
        // {"state":"end","rank":1,"totalScore":1419,"isWinner":true...}
        // debugPrint('   🏆 JUEGO TERMINADO');
        // debugPrint('   🔹 Posición Final: #${data['rank']}');
        // debugPrint('   🔹 Puntaje Total: ${data['totalScore']}');
        // if (data['isWinner'] == true) {
        //   debugPrint('   👑 ¡ERES EL GANADOR!');
        // }

        PlayerGameEnd gameEnd = PlayerGameEnd.fromJson(data);
        gameEnd.logDebugInfo();

        updatedSession = updatedSession.copyWith(
          gameStatus: GameStatus.end,
          playerGameEnd: gameEnd,
        );
        break;

      case 'session_closed':
        // {"reason":"session_closed","message":"..."}
        debugPrint('   ⛔ Sesión Cerrada');
        debugPrint('   🔹 Motivo: ${data['reason']}');
        debugPrint('   🔹 Mensaje: "${data['message']}"');

        updatedSession = updatedSession.copyWith(
          connectionStatus: ConnectionStatus.disconected,
          gameStatus: GameStatus.none,
          message: data['message'] as String?,
        );
        break;

      case 'host_results':
        break;

      case 'host_game_end':
        break;

      default:
        debugPrint('   ⚠️ Evento no manejado en el switch, data cruda: $data');
    }
    _currentGameSession = updatedSession;
    _sessionController.add(_currentGameSession);
  }

  @override
  void dispose() {
    try {
      if (_socket.connected) {
        _socket.disconnect();
      }

      _socket.clearListeners();

      _socket.dispose();
    } catch (e) {
      debugPrint('❌ Error al disponer el socket: $e');
    }
    _currentGameSession = const MultiplayerGameSession();
  }

  @override
  Future<String> createGame(String quizId) {
    throw UnimplementedError();
  }

  @override
  Future<void> startGame() {
    // Host
    throw UnimplementedError();
  }

  @override
  Future<void> nextPhase() {
    // Host
    throw UnimplementedError();
  }

  @override
  Future<void> submitAnswer(
    List<String> answersId,
    String questionId,
    int timeElapsedMs,
  ) async {
    // Jugador
    debugPrint('📤 Enviando respuesta(s): $answersId');
    _socket.emit('player_submit_answer', {
      "questionId": questionId,
      "answerId": answersId,
      "timeElapsedMs": timeElapsedMs,
    });
  }
}



// void main() async {
//   try {
//     MultiplayerGameRepository repo = MultiplayerGameRepository();

//     // JWT Hardcodeado del ejemplo
//     final jwtPrueba =
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImEyNWMxMTg5LWQzYzAtNDk5MC04ZTMwLWU1ZjU2MDNjMjAyYyIsImVtYWlsIjoiYXJhdXN5dGFAY29ycmVvLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY4MDk0MTkwLCJleHAiOjE3NjgxMDEzOTB9.44UREdgx-VTmlrDnLjzYotYGMLUdrq4e23Ed2bDpL-c';

//     await repo.connectToGame(
//       '7161508',
//       'TestPlayer',
//       jwtPrueba,
//       GameRole.player,
//     );

//     // 2. LLAMAMOS AL MÉTODO MANUALMENTE
//     //repo.notifyClientReady();

//     debugPrint("⏳ Manteniendo script vivo...");
//     await Future.delayed(const Duration(seconds: 60));
//   } catch (e) {
//     debugPrint('Error fatal: $e');
//   }

  
// }