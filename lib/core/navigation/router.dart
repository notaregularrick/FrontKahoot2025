import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/navbar.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/game_orchestrator.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/join_game.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/library_screen.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation:
        '/join', // Aquí se coloca la ruta inical (pueden ir cambiandola para probar sus pantallas)
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // ---------------------------------------------------------
          // NOTA: SHELL ROUTE es para las Pantallas que tienen barra de navegación (se llega desde una pantalla de la barra de navegación, como rutas anidadas)
          //StatefulShellBranch es cada rama de la barra de navegación
          // ---------------------------------------------------------
          // Rama 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                // Usamos un placeholder simple si aún no desarrollaste la pantalla de Home
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text("HOME - Punto de partida")),
                ),
              ),
              // Aquí irán las rutas hijas de Home (ej: /home/other)
            ],
          ),
          //Rama 1: Library (TU TRABAJO)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) =>
                    const LibraryScreen(), // Tu pantalla
              ),
            ],
          ),
        ],
      ),
      // ---------------------------------------------------------
      // B. Rutas con pantalla completa, sin barra de navegación (GoRoute)
      // ---------------------------------------------------------
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinGameScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameOrchestratorScreen(),
      ),
    ],
  );
});
