import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/models/multiplayer_game_notifier_state.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_end_game_view.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_lobby_view.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_question_view.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_results_view.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_waiting_view.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

// --- Importamos los widgets hijos (que definiremos abajo o en archivos separados) ---
// import 'widgets/player_lobby_view.dart';
// import 'widgets/player_gamepad_view.dart';
// ...

class PlayerGameScreen extends ConsumerStatefulWidget {
  const PlayerGameScreen({super.key});

  @override
  ConsumerState<PlayerGameScreen> createState() => _PlayerGameScreenState();
}

class _PlayerGameScreenState extends ConsumerState<PlayerGameScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(multiplayerGameNotifierProvider).value!;
    String title = '';
    switch (state.session.status) {
      case GameStatus.connecting:
        title = 'Conectando...';
        break;
      case GameStatus.lobby:
        title = 'Sala de Espera';
        break;
      case GameStatus.question:
        title = 'Pregunta';
        break;
      case GameStatus.results:
        title = 'Resultados';
        break;
      case GameStatus.end:
        title = 'Fin del Juego';
        break;
    }

    //Errores leves (mostrar SnackBar)
    ref.listen(multiplayerGameNotifierProvider, (previous, next) {
      final currentMsg = next.value?.errorMessage;
      final prevMsg = previous?.value?.errorMessage;

      if (currentMsg != null && currentMsg != prevMsg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentMsg),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    //
    return Scaffold(
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
        //Desactivar botón de salida automático
        automaticallyImplyLeading: false,
        actions: [
          //Botón de salida
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showExitConfirmation(context),
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),//Para transiciones
        child: _buildContent(state),
      ),
    );
  }

  Widget _buildContent(GameNotifierState state) {
    //Según el estado se meustra un widget u otro
    switch (state.session.status) {
      case GameStatus.connecting:
        return const Center(child: CircularProgressIndicator());

      case GameStatus.lobby:
        return PlayerLobbyView(
          quizTitle: state.session.quizTitle ?? "Quiz",
          gamePin: state.session.pin,
          players: state.session.players,
          myPlayerId: state.myPlayerId!,
        );

      case GameStatus.question:
        if (state.hasAnsweredCurrentQuestion) {
          return const PlayerWaitingView();
        }
        return PlayerQuestionView(
          question: state.session.currentQuestion!,
          onAnswer: (index) {
            ref
                .read(multiplayerGameNotifierProvider.notifier)
                .submitAnswer(index);
          },
        );

      case GameStatus.results:
        return PlayerResultsView(
          isCorrect:
              state.session.pointsEarned != null &&
              state.session.pointsEarned! > 0,
          pointsEarned: state.session.pointsEarned ?? 0,
          correctAnswerText: state.session.correctAnswerText,
          scoreboard: state.session.playerScoreboard,
          myPlayerId: state.myPlayerId ?? "",
        );

      case GameStatus.end:
        return PlayerGameEndView(
          finalScoreboard:
              state.session.playerScoreboard, // <--- Lista completa
          myPlayerId: state.myPlayerId ?? "",
          winnerNickname: state.session.winnerNickname ?? "Ganador",
        );
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Salir del juego?"),
        content: const Text("Si sales perderás tu progreso actual."), //Temporal?
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra dialogo
              // Navegar a la pantalla 'Unirse' dentro del shell (muestra la barra de navegación)
              context.go('/join');
            },
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}