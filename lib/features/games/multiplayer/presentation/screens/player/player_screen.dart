import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/models/multiplayer_game_notifier_state.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_end_game_view.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_lobby_view.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_question_view.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_results_view.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_waiting_view.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:go_router/go_router.dart';

class PlayerGameScreen extends ConsumerStatefulWidget {
  const PlayerGameScreen({super.key});

  @override
  ConsumerState<PlayerGameScreen> createState() => _PlayerGameScreenState();
}

class _PlayerGameScreenState extends ConsumerState<PlayerGameScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el estado. Usamos value! asumiendo que ya cargó,
    // pero idealmente deberías manejar loading/error aquí también.
    final asyncState = ref.watch(multiplayerGameNotifierProvider);

    return asyncState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (state) {
        // Título dinámico según fase
        String title = _getTitleForStatus(state.session.gameStatus);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _showExitConfirmation(context);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => _showExitConfirmation(context),
                ),
              ],
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(state),
            ),
          ),
        );
      },
    );
  }

  String _getTitleForStatus(GameStatus status) {
    switch (status) {
      case GameStatus.lobby:
        return 'Sala de Espera';
      case GameStatus.question:
        return 'Pregunta';
      case GameStatus.answerSubmitted:
        return 'Enviado';
      case GameStatus.results:
        return 'Resultados';
      case GameStatus.end:
        return 'Fin del Juego';
      default:
        return 'Conectando...';
    }
  }

  Widget _buildContent(GameNotifierState state) {
    switch (state.session.gameStatus) {
      case GameStatus.none:
      case GameStatus.lobby:
        // return PlayerLobbyView(
        //   gamePin: state.session.pin,
        //   myNickname: state.myPlayerId ?? state.session.nickname,
        // );
        return Text("Sala de espera - En desarrollo");

      case GameStatus.question:
        // Si no hay pregunta cargada, mostramos carga
        if (state.session.currentQuestion == null) {
          return const Center(child: CircularProgressIndicator());
        }
        // return PlayerQuestionView(
        //   question: state.session.currentQuestion!,
        //   // isLoading: state.isLoading, // Opcional si quieres mostrar spinner al enviar
        //   onAnswer: (index) {
        //     ref
        //         .read(multiplayerGameNotifierProvider.notifier)
        //         .submitAnswer(index);
        //   },
        // );
        return Text("Pregunta - En desarrollo");

      case GameStatus.answerSubmitted:
        return const PlayerWaitingView();

      case GameStatus.results:
        final results = state.session.playerResults;
        if (results == null)
          return const Center(child: CircularProgressIndicator());

        // return PlayerResultsView(
        //   results: results,
        //   myNickname: state.myPlayerId ?? "Yo",
        // );
        return Text("Resultados - En desarrollo");

      case GameStatus.end:
        final endGame = state.session.playerGameEnd;
        if (endGame == null){
          return const Center(child: CircularProgressIndicator());
        }
          

        // return PlayerGameEndView(
        //   gameEnd: endGame,
        //   myNickname: state.myPlayerId ?? "Yo",
        //   onQuit: () {
        //     ref.read(multiplayerGameNotifierProvider.notifier).leaveGame();
        //     context.go('/join');
        //   },
        // );
        return Text("Fin del juego - En desarrollo");
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Salir del juego?"),
        content: const Text("Perderás tu progreso actual."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(multiplayerGameNotifierProvider.notifier).leaveGame();
              context.go('/join');
            },
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/models/multiplayer_game_notifier_state.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_end_game_view.dart';
// import 'package:go_router/go_router.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_lobby_view.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_question_view.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_results_view.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_waiting_view.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

// // --- Importamos los widgets hijos (que definiremos abajo o en archivos separados) ---
// // import 'widgets/player_lobby_view.dart';
// // import 'widgets/player_gamepad_view.dart';
// // ...

// class PlayerGameScreen extends ConsumerStatefulWidget {
//   const PlayerGameScreen({super.key});

//   @override
//   ConsumerState<PlayerGameScreen> createState() => _PlayerGameScreenState();
// }

// class _PlayerGameScreenState extends ConsumerState<PlayerGameScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(multiplayerGameNotifierProvider).value!;
//     String title = '';
//     switch (state.session.gameStatus) {
//       case GameStatus.connecting:
//         title = 'Conectando...';
//         break;
//       case GameStatus.lobby:
//         title = 'Sala de Espera';
//         break;
//       case GameStatus.question:
//         title = 'Pregunta';
//         break;
//       case GameStatus.results:
//         title = 'Resultados';
//         break;
//       case GameStatus.end:
//         title = 'Fin del Juego';
//         break;
//     }

//     //Errores leves (mostrar SnackBar)
//     ref.listen(multiplayerGameNotifierProvider, (previous, next) {
//       final currentMsg = next.value?.errorMessage;
//       final prevMsg = previous?.value?.errorMessage;

//       if (currentMsg != null && currentMsg != prevMsg) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(currentMsg),
//             backgroundColor: Colors.orange,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     });

//     //
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;
//         _showExitConfirmation(context); // Muestra tu diálogo al intentar salir
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: AppColors.primaryRed,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           title: Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//           //Desactivar botón de salida automático
//           automaticallyImplyLeading: false,
//           actions: [
//             //Botón de salida
//             IconButton(
//               icon: const Icon(Icons.exit_to_app),
//               onPressed: () => _showExitConfirmation(context),
//             ),
//           ],
//         ),

//         body: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300), //Para transiciones
//           child: _buildContent(state),
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(GameNotifierState state) {
//     //Según el estado se meustra un widget u otro
//     switch (state.session.status) {
//       case GameStatus.connecting:
//         return const Center(child: CircularProgressIndicator());

//       case GameStatus.lobby:
//         return PlayerLobbyView(
//           quizTitle: state.session.quizTitle ?? "Quiz",
//           gamePin: state.session.pin,
//           players: state.session.players,
//           myPlayerId: state.myPlayerId!,
//         );

//       case GameStatus.question:
//         if (state.hasAnsweredCurrentQuestion) {
//           return const PlayerWaitingView();
//         }
//         return PlayerQuestionView(
//           question: state.session.currentQuestion!,
//           onAnswer: (index) {
//             ref
//                 .read(multiplayerGameNotifierProvider.notifier)
//                 .submitAnswer(index);
//           },
//         );

//       case GameStatus.results:
//         return PlayerResultsView(
//           isCorrect:
//               state.session.pointsEarned != null &&
//               state.session.pointsEarned! > 0,
//           pointsEarned: state.session.pointsEarned ?? 0,
//           correctAnswerText: state.session.correctAnswerText,
//           scoreboard: state.session.playerScoreboard,
//           myPlayerId: state.myPlayerId ?? "",
//         );

//       case GameStatus.end:
//         return PlayerGameEndView(
//           finalScoreboard:
//               state.session.playerScoreboard, // <--- Lista completa
//           myPlayerId: state.myPlayerId ?? "",
//           winnerNickname: state.session.winnerNickname ?? "Ganador",
//           onQuit: () {
//             ref.read(multiplayerGameNotifierProvider.notifier).leaveGame();
//             // 2. Navegamos
//             context.go('/join');
//           },
//         );
//     }
//   }

//   void _showExitConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("¿Salir del juego?"),
//         content: const Text(
//           "Si sales perderás tu progreso actual.",
//         ), //Temporal?
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancelar"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Cierra dialogo
//               // Navegar a la pantalla 'Unirse' dentro del shell (muestra la barra de navegación)
//               ref.read(multiplayerGameNotifierProvider.notifier).leaveGame();
//               context.go('/join');
//             },
//             child: const Text("Salir", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }
