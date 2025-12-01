
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/navbar.dart';
//import 'package:frontkahoot2526/features/presentation/screens/library_screen.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/login_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/register_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login', // Ruta inicial mientras no haya redirección
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.token != null;
      final currentLocation = state.uri.toString(); // o state.subloc si tu versión lo prefiere
      final isLoginRoute = currentLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
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
          // ---------------------------------------------------------
          // NOTA: SHELL ROUTE es para las Pantallas que tienen barra de navegación
          // ---------------------------------------------------------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text("HOME - Punto de partida")),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                //builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
});
