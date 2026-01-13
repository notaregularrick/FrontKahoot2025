import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import go_router to access StatefulNavigationShell and navigation helpers
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Map branch index (0..3) to nav index (0..4) to keep highlight correct
    final Map<int, int> branchToNavIndex = {
      0: 0, // Inicio/Descubrir
      1: 2, // Unirse (center)
      2: 1, // Crear Kahoot
      3: 3, // Biblioteca
    };
    final int selectedNavIndex = branchToNavIndex[navigationShell.currentIndex] ?? navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedNavIndex,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
        onDestinationSelected: (index) async {
          // Map bottom nav indices to shell branches or direct routes:
          // 0: Inicio        -> branch 0
          // 1: Crear Kahoot  -> branch 2
          // 2: Unirse        -> branch 1 (center, highlighted)
          // 3: Biblioteca    -> branch 3
          // 4: Perfil        -> push '/profile' (full-screen)

          if (index >= 0 && index <= 3) {
            // Reordered mapping to match new destination order
            final List<int> branchMap = [0, 2, 1, 3];
            final int branchIndex = branchMap[index];
            navigationShell.goBranch(
              branchIndex,
              initialLocation: branchIndex == navigationShell.currentIndex,
            );
            return;
          }

          if (index == 4) {
            // Perfil (no es una branch del shell)
            if (context.mounted) context.push('/profile');
            return;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Descubrir'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Crear\nKahoot'),
          // 2: Unirse (center, slightly larger icon)
          NavigationDestination(
            icon: Icon(Icons.videogame_asset, size: 30),
            selectedIcon: Icon(Icons.videogame_asset, size: 34),
            label: 'Unirse',
          ),
          // 3: Biblioteca
          NavigationDestination(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          // 4: Perfil
          NavigationDestination(icon: Icon(Icons.person_2), label: 'Perfil'),
        ],
      ),
    );
  }
}