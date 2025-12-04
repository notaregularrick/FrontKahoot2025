import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/navbar.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/game_orchestrator.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/join_game.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/library_screen.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/library_home_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/groups_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/join_group_screen.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/library', // Ruta inicial por defecto
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
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryHomeScreen(), // Home that shows two buttons
              ),
              GoRoute(
                path: '/library/quices',
                builder: (context, state) => const LibraryScreen(), // The detailed library screen
              ),
              GoRoute(
                path: '/groups',
                builder: (context, state) => const GroupsScreen(),
              ),
              GoRoute(
                path: '/groups/:groupId',
                builder: (context, state) {
                  final id = state.pathParameters['groupId']!;
                  return GroupDetailScreen(groupId: id);
                },
              ),
              GoRoute(
                path: '/library/quices',
                builder: (context, state) => const LibraryScreen(), // The detailed library screen
              ),
              GoRoute(
                path: '/groups',
                builder: (context, state) => const GroupsScreen(),
              ),
              GoRoute(
                path: '/groups/:groupId',
                builder: (context, state) {
                  final id = state.pathParameters['groupId']!;
                  return GroupDetailScreen(groupId: id);
                },
=======
                builder: (context, state) =>
                    const LibraryScreen(), // Tu pantalla
>>>>>>> origin/synchronous-game-branch
              ),
            ],
          ),
        ],
      ),
      // ---------------------------------------------------------
      // ---------------------------------------------------------
      // B. Rutas con pantalla completa, sin barra de navegación (GoRoute)
      // ---------------------------------------------------------
<<<<<<< HEAD
      // Invite deep link route (public) - opens join screen for groups
      GoRoute(
        path: '/groups/join/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return JoinGroupScreen(token: token);
        },
      ),
      // Multiplayer / synchronous-game routes (from synchronous-game-branch)
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinGameScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameOrchestratorScreen(),
      ),
=======
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinGameScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameOrchestratorScreen(),
      ),
>>>>>>> origin/synchronous-game-branch
    ],
  );
});
