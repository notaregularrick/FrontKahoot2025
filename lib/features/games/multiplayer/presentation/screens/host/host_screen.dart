import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart'; // Ajusta tus imports
import 'package:go_router/go_router.dart';

class HostGameScreen extends ConsumerStatefulWidget {
  final String quizId;

  const HostGameScreen({
    super.key,
    required this.quizId,
  });

  @override
  ConsumerState<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends ConsumerState<HostGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(multiplayerGameNotifierProvider.notifier).createGame(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(multiplayerGameNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Panel de Control (Host)"),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Quitamos botón de atrás default
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmCloseSession(context),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Creando sala en el servidor..."),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: $err", textAlign: TextAlign.center),
              ),
              ElevatedButton(
                onPressed: () => context.go('/home'), // O a donde quieras volver
                child: const Text("Volver"),
              )
            ],
          ),
        ),
        data: (state) {
          return Column(
            children: [
              // 1. HEADER CON EL PIN
              _buildPinHeader(state.session.pin),

              // 2. ESTADO ACTUAL Y CONTENIDO
              Expanded(
                child: _buildMainContent(state.session.gameStatus),
              ),

              // 3. BARRA DE CONTROL INFERIOR (Los 3 botones)
              _buildControlBar(state.session.gameStatus),
            ],
          );
        },
      ),
    );
  }



  Widget _buildPinHeader(String pin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            "PIN DEL JUEGO",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: pin));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("PIN copiado al portapapeles")),
              );
            },
            child: Text(
              pin.isEmpty ? "..." : pin,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBlueText,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(GameStatus status) {
    // Aquí puedes usar Selectors si quieres optimizar más, 
    // pero para el Host ver el estado general está bien.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getIconForStatus(status), size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            "Estado: ${status.name.toUpperCase()}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (status == GameStatus.lobby)
             const HostLobbyCounter(), // Widget extraído para optimizar (ver abajo)
        ],
      ),
    );
  }

  Widget _buildControlBar(GameStatus status) {
    final notifier = ref.read(multiplayerGameNotifierProvider.notifier);

    // Lógica visual para habilitar/deshabilitar botones según fase
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
            // BOTÓN 1: START GAME
            Expanded(
              child: _ControlButton(
                icon: Icons.play_arrow_rounded,
                label: "START",
                color: Colors.green,
                onPressed: canStart ? () => notifier.startGame() : null,
              ),
            ),
            const SizedBox(width: 10),

            // BOTÓN 2: NEXT PHASE
            Expanded(
              child: _ControlButton(
                icon: Icons.skip_next_rounded,
                label: "NEXT",
                color: Colors.blue,
                onPressed: canNext ? () => notifier.nextPhase() : null,
              ),
            ),
            const SizedBox(width: 10),

            // BOTÓN 3: END SESSION
            Expanded(
              child: _ControlButton(
                icon: Icons.stop_rounded,
                label: "END",
                color: Colors.red,
                onPressed: () => _confirmCloseSession(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCloseSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Cerrar Sesión?"),
        content: const Text("Esto desconectará a todos los jugadores."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // 1. Mandar señal al server para matar la sala
              ref.read(multiplayerGameNotifierProvider.notifier).endSession();
              // 2. Limpiar localmente
              ref.read(multiplayerGameNotifierProvider.notifier).leaveGame();
              // 3. Salir
              context.go('/home'); // O a tu pantalla principal
            },
            child: const Text("Finalizar"),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus(GameStatus status) {
    switch (status) {
      case GameStatus.lobby: return Icons.people_outline;
      case GameStatus.question: return Icons.help_outline;
      case GameStatus.results: return Icons.bar_chart;
      case GameStatus.end: return Icons.emoji_events_outlined;
      default: return Icons.hourglass_empty;
    }
  }
}

// --- WIDGETS AUXILIARES ---

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Widget extraído para escuchar SOLO cambios en el lobby (HostLobby)
class HostLobbyCounter extends ConsumerWidget {
  const HostLobbyCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Selector específico para el conteo de jugadores
    final playerCount = ref.watch(
      multiplayerGameNotifierProvider.select(
        (state) => state.value?.session.hostLobby?.totalPlayers ?? 0
      )
    );

    return Text(
      "$playerCount Jugadores unidos",
      style: const TextStyle(fontSize: 18, color: Colors.grey),
    );
  }
}