import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/models/multiplayer_game_notifier_state.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/host/host_endgame_view.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/host/host_lobby_view.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/host/host_question_view.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/host/host_results_view.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:go_router/go_router.dart';

class HostGameScreen extends ConsumerStatefulWidget {
  final String quizId;

  const HostGameScreen({super.key, required this.quizId});

  @override
  ConsumerState<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends ConsumerState<HostGameScreen> {
  @override
  void initState() {
    super.initState();
    // Iniciamos la creación del juego al cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(multiplayerGameNotifierProvider.notifier)
          .createGame(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(multiplayerGameNotifierProvider);

    return asyncState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (state) {
        final status = state.session.gameStatus;
        final title = _getTitleForStatus(status);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _showExitConfirmation(context);
          },
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _showExitConfirmation(context),
                ),
              ],
            ),
            // Barra de control fija abajo
            bottomNavigationBar: _buildControlBar(status),

            // Switch de Vistas con Animación
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(GameNotifierState state) {
    switch (state.session.gameStatus) {
      case GameStatus.none:
        return const Center(child: CircularProgressIndicator());

      case GameStatus.lobby:
        return HostLobbyView(
          quizTitle: state.quizTitle,
          coverImageUrl: state.quizImageUrl,
          pin: state.session.pin,
          // Pasamos la lista del lobby (o vacía si es null)
          players: state.session.hostLobby?.players ?? [],
        );

      case GameStatus.question:
      case GameStatus.answerSubmitted:
        final currentQ = state.session.currentQuestion;
        if (currentQ == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return HostQuestionView(
          question: currentQ,
          totalPlayers: state.session.hostLobby?.totalPlayers ?? 0,
          onTimeout: () {
            ref.read(multiplayerGameNotifierProvider.notifier).nextPhase();
          },
        );

      case GameStatus.results:
        final results = state.session.hostResults;
        if (results == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return HostResultsView(results: results);

      case GameStatus.end:
        final endGame = state.session.hostEndGame;
        if (endGame == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return HostEndGameView(
          endGame: endGame,
          quizTitle: state.quizTitle,
          coverImageUrl: state.quizImageUrl,
        );
    }
  }

  String _getTitleForStatus(GameStatus status) {
    switch (status) {
      case GameStatus.lobby:
        return "Sala de Espera";
      case GameStatus.question:
        return "Pregunta en Curso";
      case GameStatus.results:
        return "Resultados";
      case GameStatus.end:
        return "Podio Final";
      default:
        return "Cargando...";
    }
  }

  Widget _buildControlBar(GameStatus status) {
    final notifier = ref.read(multiplayerGameNotifierProvider.notifier);

    // Lógica de habilitación de botones
    final bool canStart = status == GameStatus.lobby;
    final bool canNext = status != GameStatus.lobby && status != GameStatus.end;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _ControlButton(
                icon: Icons.play_arrow_rounded,
                label: "EMPEZAR",
                color: canStart ? Colors.green : Colors.grey.shade300,
                onPressed: canStart ? () => notifier.startGame() : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ControlButton(
                icon: Icons.skip_next_rounded,
                label: "SIGUIENTE",
                color: canNext ? Colors.blue : Colors.grey.shade300,
                onPressed: canNext ? () => notifier.nextPhase() : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ControlButton(
                icon: Icons.stop_rounded,
                label: "FINALIZAR",
                color: Colors.red,
                onPressed: () => _showExitConfirmation(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Cerrar Sesión?"),
        content: const Text(
          "Esto desconectará a todos los jugadores y terminará la partida.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(multiplayerGameNotifierProvider.notifier).endSession();
              context.go('/home');
            },
            child: const Text("Finalizar Partida"),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: onPressed != null ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart'; // Ajusta tus imports
// import 'package:go_router/go_router.dart';

// class HostGameScreen extends ConsumerStatefulWidget {
//   final String quizId;

//   const HostGameScreen({
//     super.key,
//     required this.quizId,
//   });

//   @override
//   ConsumerState<HostGameScreen> createState() => _HostGameScreenState();
// }

// class _HostGameScreenState extends ConsumerState<HostGameScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(multiplayerGameNotifierProvider.notifier).createGame(widget.quizId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final asyncState = ref.watch(multiplayerGameNotifierProvider);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("Panel de Control (Host)"),
//         backgroundColor: AppColors.primaryRed,
//         foregroundColor: Colors.white,
//         automaticallyImplyLeading: false, // Quitamos botón de atrás default
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => _confirmCloseSession(context),
//           ),
//         ],
//       ),
//       body: asyncState.when(
//         loading: () => const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text("Creando sala en el servidor..."),
//             ],
//           ),
//         ),
//         error: (err, stack) => Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 60, color: Colors.red),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text("Error: $err", textAlign: TextAlign.center),
//               ),
//               ElevatedButton(
//                 onPressed: () => context.go('/home'), // O a donde quieras volver
//                 child: const Text("Volver"),
//               )
//             ],
//           ),
//         ),
//         data: (state) {
//           return Column(
//             children: [
//               // 1. HEADER CON EL PIN
//               _buildPinHeader(state.session.pin),

//               // 2. ESTADO ACTUAL Y CONTENIDO
//               Expanded(
//                 child: _buildMainContent(state.session.gameStatus),
//               ),

//               // 3. BARRA DE CONTROL INFERIOR (Los 3 botones)
//               _buildControlBar(state.session.gameStatus),
//             ],
//           );
//         },
//       ),
//     );
//   }



//   Widget _buildPinHeader(String pin) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       color: Colors.white,
//       child: Column(
//         children: [
//           const Text(
//             "PIN DEL JUEGO",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 5),
//           GestureDetector(
//             onTap: () {
//               Clipboard.setData(ClipboardData(text: pin));
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("PIN copiado al portapapeles")),
//               );
//             },
//             child: Text(
//               pin.isEmpty ? "..." : pin,
//               style: TextStyle(
//                 fontSize: 40,
//                 fontWeight: FontWeight.w900,
//                 color: AppColors.darkBlueText,
//                 letterSpacing: 2,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent(GameStatus status) {
//     // Aquí puedes usar Selectors si quieres optimizar más, 
//     // pero para el Host ver el estado general está bien.
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(_getIconForStatus(status), size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 20),
//           Text(
//             "Estado: ${status.name.toUpperCase()}",
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           if (status == GameStatus.lobby)
//              const HostLobbyCounter(), // Widget extraído para optimizar (ver abajo)
//         ],
//       ),
//     );
//   }

//   Widget _buildControlBar(GameStatus status) {
//     final notifier = ref.read(multiplayerGameNotifierProvider.notifier);

//     // Lógica visual para habilitar/deshabilitar botones según fase
//     final bool canStart = status == GameStatus.lobby;
//     final bool canNext = status != GameStatus.lobby && status != GameStatus.end;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             // BOTÓN 1: START GAME
//             Expanded(
//               child: _ControlButton(
//                 icon: Icons.play_arrow_rounded,
//                 label: "START",
//                 color: Colors.green,
//                 onPressed: canStart ? () => notifier.startGame() : null,
//               ),
//             ),
//             const SizedBox(width: 10),

//             // BOTÓN 2: NEXT PHASE
//             Expanded(
//               child: _ControlButton(
//                 icon: Icons.skip_next_rounded,
//                 label: "NEXT",
//                 color: Colors.blue,
//                 onPressed: canNext ? () => notifier.nextPhase() : null,
//               ),
//             ),
//             const SizedBox(width: 10),

//             // BOTÓN 3: END SESSION
//             Expanded(
//               child: _ControlButton(
//                 icon: Icons.stop_rounded,
//                 label: "END",
//                 color: Colors.red,
//                 onPressed: () => _confirmCloseSession(context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _confirmCloseSession(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("¿Cerrar Sesión?"),
//         content: const Text("Esto desconectará a todos los jugadores."),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               // 1. Mandar señal al server para matar la sala
//               ref.read(multiplayerGameNotifierProvider.notifier).endSession();
//               // 2. Limpiar localmente
//               ref.read(multiplayerGameNotifierProvider.notifier).leaveGame();
//               // 3. Salir
//               context.go('/home'); // O a tu pantalla principal
//             },
//             child: const Text("Finalizar"),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getIconForStatus(GameStatus status) {
//     switch (status) {
//       case GameStatus.lobby: return Icons.people_outline;
//       case GameStatus.question: return Icons.help_outline;
//       case GameStatus.results: return Icons.bar_chart;
//       case GameStatus.end: return Icons.emoji_events_outlined;
//       default: return Icons.hourglass_empty;
//     }
//   }
// }

// // --- WIDGETS AUXILIARES ---

// class _ControlButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback? onPressed;

//   const _ControlButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         disabledBackgroundColor: Colors.grey[300],
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon),
//           Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

// // Widget extraído para escuchar SOLO cambios en el lobby (HostLobby)
// class HostLobbyCounter extends ConsumerWidget {
//   const HostLobbyCounter({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Selector específico para el conteo de jugadores
//     final playerCount = ref.watch(
//       multiplayerGameNotifierProvider.select(
//         (state) => state.value?.session.hostLobby?.totalPlayers ?? 0
//       )
//     );

//     return Text(
//       "$playerCount Jugadores unidos",
//       style: const TextStyle(fontSize: 18, color: Colors.grey),
//     );
//   }
// }