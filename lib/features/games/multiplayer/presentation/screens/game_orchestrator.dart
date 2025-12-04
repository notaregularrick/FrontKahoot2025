import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_enums.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/player/player_screen.dart';
import 'package:go_router/go_router.dart';

class GameOrchestratorScreen extends ConsumerWidget {
  const GameOrchestratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRole = ref.watch(
      multiplayerGameNotifierProvider.select((state) {
        return state.whenData(
          (data) => data.role,
        ); //Extraigo solo el rola sí no se ejecuta a cada rato
      }),
    );

    return asyncRole.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stackTrace) {
        String errorMessage = "Ocurrió un error inesperado";

        if (error is AppException) {
          errorMessage = error.message;
        } else {
          errorMessage = error.toString().replaceAll('Exception:', '').trim();
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),

                  Text("¡Ups!", style: Theme.of(context).textTheme.titleLarge),

                  const SizedBox(height: 8),

                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Salir"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      data: (role) {
        switch (role) {
          case GameRole.host:
            return const PlayerGameScreen();
          case GameRole.player:
            return const PlayerGameScreen();
          case GameRole.none:
            return const Scaffold(body: Center(child: Text("Rol no asignado")));
        }
      },
    );
  }
}
