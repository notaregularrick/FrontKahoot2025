import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import go_router to access StatefulNavigationShell and navigation helpers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) async {
          // Map bottom nav indices to shell branches or direct routes:
          // 0: Inicio -> branch 0
          // 1: Unirse -> branch 1
          // 2: Crear Kahoot -> branch 2
          // 3: Biblioteca -> branch 3
          // 4: Perfil -> push '/profile' (full-screen)
          // 5: Cerrar Sesión -> logout and go '/inicio'

          if (index >= 0 && index <= 3) {
            // Navigate to the corresponding shell branch
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
            return;
          }

          if (index == 4) {
            // Perfil (no es una branch del shell)
            if (context.mounted) context.push('/profile');
            return;
          }

          if (index == 5) {
            // Cerrar sesión
            final notifier = ref.read(authNotifierProvider.notifier);
            await notifier.logout();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/inicio');
              }
            });
            return;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.videogame_asset), label: 'Unirse'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Crear\nKahoot'),
          NavigationDestination(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          NavigationDestination(icon: Icon(Icons.person_2), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.arrow_circle_left), label: 'Cerrar Sesión'),
        ],
      ),
    );
  }
}