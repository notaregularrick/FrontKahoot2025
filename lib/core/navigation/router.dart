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
          // Branch 0: Home placeholder (inline, no separate file)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Home (placeholder)')),
                ),
              ),
            ],
          ),
          // Branch 1: Join game (so navbar remains visible while joining)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/join',
                builder: (context, state) => const JoinGameScreen(),
              ),
            ],
          ),

          // Branch 2: Library-related routes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryHomeScreen(),
              ),
              GoRoute(
                path: '/library/quices',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
        ],
      ),

      // Groups routes kept as full-screen (accessible from library)
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
        path: '/groups/join/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return JoinGroupScreen(token: token);
        },
      ),

      // Multiplayer routes (keep orchestrator full-screen)
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameOrchestratorScreen(),
      ),
    ],
  );
});
