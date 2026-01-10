import 'dart:async';

// import 'package:frontkahoot2526/core/providers/backend_provider.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/game_session.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class MultiplayerGameRepository {
  //final _sessionController = StreamController<GameSession>.broadcast();
  //GameSession _state = const GameSession();

  //@override
  //Stream<GameSession> get gameStream => _sessionController.stream;

  late io.Socket _socket;

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
            'jwt':
                jwt,
            'pin': pin,
            'role': role == GameRole.host ? 'HOST' : 'PLAYER',
          })
          .build(),
    );

    // _socket.onAny((event, data) {
    //   print('Llegó evento: "$event"');
    //   print('Datos: $data');
    // });

    // Eventos de conexión física
    _socket.onConnect((_) {
      print('✅ Socket Conectado (ID: ${_socket.id})');
      // _socket.emit('client_ready');
      // _socket.emit('player_join', {"nickname": nickname});
      _socket.emit('client_ready');
      _socket.emit('player_join', {"nickname": nickname});
    });

    _socket.onConnectError((data) => print(' Error de conexión: $data'));

    _socket.onDisconnect((reason) {
      print('🔌 Desconectado. Razón: $reason');
    });

    //Listeners de eventos del juego:
    _socket.on('player_connected_to_server', (data) {
      _handleEvent('player_connected_to_server', data);
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

    _socket.connect();
  }

  // void notifyClientReady() {
  //   // Verificamos si _socket ha sido inicializada y si está conectada
  //   try {
  //     if (_socket.connected) {
  //       print('📤 [MANUAL] Enviando: client_ready');
  //       // _socket.emit('client_ready');
  //       // _socket.emit('player_join', {"nickname": "TestPlayer"});
  //     } else {
  //       print(
  //         '⚠️ No se pudo enviar client_ready: El socket no está conectado.',
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Error al intentar emitir: $e');
  //   }
  // }


  //EVENT HANDLER
  void _handleEvent(String eventName, dynamic payload) {
    print('\n📥 [EVENTO] $eventName');

    // Validación básica: casi siempre esperamos un Mapa (JSON Object)
    if (payload is! Map) {
      print('   ⚠️ Data no es un Mapa: $payload');
      return;
    }

    final data = Map<String, dynamic>.from(payload);

    switch (eventName) {
      case 'player_connected_to_server':
        // {"status":"CONNECTED TO SERVER"}
        print('   🔹 Status: ${data['status']}');
        break;

      case 'player_connected_to_session':
        // {"state":"lobby","nickname":"Carlitos","score":0,"connectedBefore":false}
        print('   🔹 Estado: ${data['state']}');
        print('   🔹 Nickname: ${data['nickname']}');
        print('   🔹 Score Inicial: ${data['score']}');
        break;

      case 'question_started':
        // Data compleja con "currentSlideData"
        final slide = data['currentSlideData'];
        print('   🔹 Estado: ${data['state']}');
        
        if (slide != null) {
          print('   ❓ Pregunta: "${slide['questionText']}"');
          print('   ⏱️ Tiempo: ${slide['timeLimitSeconds']}s');
          print('   🖼️ Imagen: ${slide['slideImageURL'] ?? "Sin imagen"}');
          
          final options = slide['options'] as List?;
          if (options != null) {
            print('   🔠 Opciones (${options.length}):');
            for (var opt in options) {
              print('      - [${opt['index']}] ${opt['text'] ?? "Imagen: ${opt['mediaURL']}"}');
            }
          }
        }
        break;

      case 'player_answer_confirmation':
        // {"status":"ANSWER SUCCESFULLY SUBMITTED"}
        print('   ✅ Status: ${data['status']}');
        break;

      case 'player_results':
        // {"state":"results","isCorrect":true,"pointsEarned":932...}
        final isCorrect = data['isCorrect'] == true;
        print('   🔹 Resultado: ${isCorrect ? "¡CORRECTO! 🎉" : "Incorrecto ❌"}');
        print('   🔹 Puntos ganados: ${data['pointsEarned']}');
        print('   🔹 Racha: ${data['streak']} 🔥');
        print('   🔹 Ranking actual: #${data['rank']}');
        print('   🔹 Mensaje: "${data['message']}"');
        
        // Accediendo al objeto anidado "progress"
        if (data['progress'] != null) {
          print('   📊 Progreso: ${data['progress']['current']}/${data['progress']['total']}');
        }
        break;

      case 'player_game_end':
        // {"state":"end","rank":1,"totalScore":1419,"isWinner":true...}
        print('   🏆 JUEGO TERMINADO');
        print('   🔹 Posición Final: #${data['rank']}');
        print('   🔹 Puntaje Total: ${data['totalScore']}');
        if (data['isWinner'] == true) {
          print('   👑 ¡ERES EL GANADOR!');
        }
        break;

      case 'session_closed':
        // {"reason":"session_closed","message":"..."}
        print('   ⛔ Sesión Cerrada');
        print('   🔹 Motivo: ${data['reason']}');
        print('   🔹 Mensaje: "${data['message']}"');
        break;

      default:
        print('   ⚠️ Evento no manejado en el switch, data cruda: $data');
    }
  }
}

void main() async {
  try {
    MultiplayerGameRepository repo = MultiplayerGameRepository();

    // JWT Hardcodeado del ejemplo
    final jwtPrueba =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImEyNWMxMTg5LWQzYzAtNDk5MC04ZTMwLWU1ZjU2MDNjMjAyYyIsImVtYWlsIjoiYXJhdXN5dGFAY29ycmVvLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY4MDg2NjM4LCJleHAiOjE3NjgwOTM4Mzh9.t8q1mc1zwpmE6LcpJc5G0jhmUcm5lGFC-AJ82DEkC2I';

    await repo.connectToGame(
      '24644552',
      'TestPlayer',
      jwtPrueba,
      GameRole.player,
    );

    // 2. LLAMAMOS AL MÉTODO MANUALMENTE
    //repo.notifyClientReady();

    print("⏳ Manteniendo script vivo...");
    await Future.delayed(const Duration(seconds: 60));
  } catch (e) {
    print('Error fatal: $e');
  }

  
}