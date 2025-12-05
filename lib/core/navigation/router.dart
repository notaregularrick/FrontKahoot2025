import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/home_page.dart';
import 'package:frontkahoot2526/core/navigation/navbar.dart';
import 'package:frontkahoot2526/features/auth/games/multiplayer/presentation/screens/game_orchestrator.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/screens/join_game.dart';
import 'package:frontkahoot2526/features/library/presentation/pages/edit_profile_page.dart';
//import 'package:frontkahoot2526/features/presentation/screens/library_screen.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/login_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/password_change_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/password_reset_confirm_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/password_reset_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/profile_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/register_page.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/library_home_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/groups_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:frontkahoot2526/features/groups/presentation/screens/join_group_screen.dart';
import 'package:frontkahoot2526/features/games/singleplayer/presentation/screens/singleplayer_orchestrator_screen.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/screens/create_kahoot_screen.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/screens/from_scratch_screen.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/screens/quiz_metadata_screen.dart';
import 'package:go_router/go_router.dart';

//import '../../features/auth/presentation/providers/auth_providers.dart';
import 'inicio.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  //final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/inicio', // Ruta inicial mientras no haya redirección
    //logica de redireccion deprecada por interferir en la simulacion
    /*redirect: (BuildContext context, GoRouterState state) {
      print("/nTOKEN ACTUAL: ${ref.read(authNotifierProvider).token}/n");
      final isLoggedIn = authState.token != null;
      final currentLocation = state.uri.toString();
      final isLoginRoute = currentLocation == '/login';
      final isRegisterRoute = currentLocation == '/register'; // Añadido
      final isPassResetRoute = currentLocation == '/passreset';
      final isPassConfirmRoute = currentLocation == '/passconfirm';
      final isTitleRoute = currentLocation == '/inicio';

      // Si no está logueado y está intentando acceder a rutas protegidas, redirige a login
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute && !isPassResetRoute && !isPassConfirmRoute && !isTitleRoute) {
        return '/inicio';
      }

      if (isLoggedIn && isTitleRoute) return '/home';

      // Si está logueado y entra en /login, redirige a home
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }

      if (isLoggedIn && isRegisterRoute) return '/home';

      if (isLoggedIn && isPassResetRoute) return '/home';

      if(isLoggedIn && isPassConfirmRoute) return '/home';

      // Si nada de lo anterior, deja el flujo continuar normalmente
      return null;
    },*/
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
          //Branch 2: Create Kahoot
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create-kahoot',
                builder: (context, state) => const CreateKahootScreen(), // Pantalla de selección
                routes: [
                  GoRoute(
                    path: 'quiz-metadata',
                    builder: (context, state) => const QuizMetadataScreen(), // Pantalla de metadata
                  ),
                  GoRoute(
                    path: 'from-scratch',
                    builder: (context, state) => const FromScratchScreen(), // Pantalla de edición
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Library-related routes
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

      // Singleplayer full-screen route (hide navbar when playing)
      GoRoute(
        path: '/library/singleplayer/:kahootId',
        builder: (context, state) {
          final id = state.pathParameters['kahootId']!;
          return SingleplayerOrchestratorScreen(kahootId: id);
        },
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
      GoRoute(
        path: '/inicio',
        builder: (context, state) => const TitlePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/passreset',
        builder: (context, state) => const PasswordResetPage(),
      ),
      GoRoute(
        path: '/passchange',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/passconfirm',
        builder: (context, state) => const PasswordResetConfirmPage(),
      ),
      GoRoute(path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
      )
    ],
  );
});
