import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- IMPORTS ---
// Core
import 'package:frontkahoot2526/core/navigation/navbar.dart';
import 'package:frontkahoot2526/core/presentation/change_backend_screen.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/host/host_screen.dart';
import '../../features/explore/presentation/screens/quiz_detail_screen.dart';
import 'inicio.dart';

// Auth
import 'package:frontkahoot2526/features/auth/presentation/pages/login_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/password_change_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/profile_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/register_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/providers/auth_providers.dart';

// Features
import 'package:frontkahoot2526/features/library/presentation/screens/library_home_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/groups_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/join_group_screen.dart';
import 'package:frontkahoot2526/features/games/singleplayer/presentation/screens/singleplayer_orchestrator_screen.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/screens/create_kahoot_screen.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/screens/from_scratch_screen.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/screens/quiz_metadata_screen.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/screens/template_preview_screen.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/library_screen.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/screens/personal_results_secreen.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/screens/reports_screen.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/screens/session_report_screen.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/game_orchestrator.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/join_game.dart';
import 'package:frontkahoot2526/features/explore/presentation/screens/explore_screen.dart';

// Quiz
//import '../../quiz/presentation/screens/quiz_detail_screen.dart';
import '../../features/explore/domain/entities/quiz_entity.dart';

// --- UTILIDAD PARA ESCUCHAR RIVERPOD EN GOROUTER ---
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// --- PROVIDER DEL ROUTER ---
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/inicio',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    
    
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.token != null;
      final isLoading = authState.isLoading;

      if (isLoading && !isLoggedIn) return null;

      final currentPath = state.uri.path;
      
      // Rutas públicas (No requieren login)
      final publicRoutes = [
        '/inicio', 
        '/login', 
        '/register', 
        '/passreset', 
        '/passconfirm', 
        '/passchange',
        '/back-settings'
      ];
      final isPublicRoute = publicRoutes.any((route) => currentPath.startsWith(route));

      if (!isLoggedIn && !isPublicRoute) {
        return '/inicio';
      }

      if (isLoggedIn && (currentPath == '/login' || currentPath == '/register' || currentPath == '/inicio')) {
        return '/home';
      }

      return null;
    },

    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Explore Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          // Join Game Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/join',
                builder: (context, state) => const JoinGameScreen(),
              ),
            ],
          ),
          // Create Kahoot Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create-kahoot',
                builder: (context, state) => const CreateKahootScreen(),
                routes: [
                  GoRoute(
                    path: 'quiz-metadata',
                    builder: (context, state) => const QuizMetadataScreen(),
                  ),
                  GoRoute(
                    path: 'from-scratch',
                    builder: (context, state) => const FromScratchScreen(),
                  ),
                  GoRoute(
                    path: 'template/:templateId',
                    builder: (context, state) {
                      final templateId = state.pathParameters['templateId']!;
                      return TemplatePreviewScreen(templateId: templateId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Library Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'quices',
                    builder: (context, state) => const LibraryScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // --- RUTAS GLOBALES (Fuera del Shell/Navbar) ---
      
      // Detalle del Quiz (Corregido para estar en la raíz)
      GoRoute(
        path: '/quiz/:quizId',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId'] ?? 'no-id';
          final quiz = state.extra as QuizEntity?; 
          return QuizDetailScreen(quizId: quizId, quizSummary: quiz);
        },
      ),

      // Rutas de Auth
      GoRoute(path: '/inicio', builder: (context, state) => const TitlePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfilePage()),
      GoRoute(path: '/passchange', builder: (context, state) => const ChangePasswordPage()),
      GoRoute(path: '/back-settings', builder: (context, state) => const ChangeBackendScreen()),

      // Rutas de Juego y Grupos
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameOrchestratorScreen(),
      ),
      GoRoute(
        path: '/hostGame/:quizId',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return HostGameScreen(quizId: quizId);
        },
      ),
      GoRoute(
        path: '/library/singleplayer/:kahootId',
        builder: (context, state) {
          final id = state.pathParameters['kahootId']!;
          final attemptId = state.uri.queryParameters['attemptId'];
          return SingleplayerOrchestratorScreen(kahootId: id, attemptId: attemptId);
        },
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
        path: '/groups/join/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return JoinGroupScreen(token: token);
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const PlayerReportsScreen(),
      ),
      GoRoute(
        path: '/reports/sessionReport/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return SessionReportScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/reports/personalResults/:gameId/:typeName',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          final typeName = state.pathParameters['typeName']!;
          final gameType = typeName == 'multiplayer'
              ? GameType.multiplayerPlayer
              : GameType.singleplayer;
          return PersonalResultsScreen(gameId: gameId, gameType: gameType);
        },
      ),
    ],
    
    // Página de Error Genérica
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Página no encontrada: ${state.uri.path}'),
      ),
    ),
  );
});