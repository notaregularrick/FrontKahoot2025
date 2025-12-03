
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/navbar.dart';
//import 'package:frontkahoot2526/features/presentation/screens/library_screen.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/login_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/password_change_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/password_reset_confirm_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/password_reset_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/profile_page.dart';
import 'package:frontkahoot2526/features/auth/presentation/pages/register_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login', // Ruta inicial mientras no haya redirección
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.token != null;
      final currentLocation = state.uri.toString();
      final isLoginRoute = currentLocation == '/login';
      final isRegisterRoute = currentLocation == '/register'; // Añadido
      final isPassResetRoute = currentLocation == '/passreset';
      final isPassConfirmRoute = currentLocation == '/passconfirm';

      // Si no está logueado y está intentando acceder a rutas protegidas, redirige a login
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute && !isPassResetRoute && !isPassConfirmRoute) {
        return '/login';
      }

      // Si está logueado y entra en /login, redirige a home
      if (isLoggedIn && isLoginRoute) {
        return '/profile';
      }

      if (isLoggedIn && isRegisterRoute) return '/profile';

      if (isLoggedIn && isPassResetRoute) return '/profile';

      if(isLoggedIn && isPassConfirmRoute) return '/profile';

      // Si nada de lo anterior, deja el flujo continuar normalmente
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
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text("TEMP PROFILE")),
              ),
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
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
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
    ],
  );
});
