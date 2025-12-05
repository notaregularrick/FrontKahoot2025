import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import go_router to access StatefulNavigationShell and navigation helpers

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Crear Kahoot'),
          NavigationDestination(icon: Icon(Icons.videogame_asset), label: 'Unirse'),
          NavigationDestination(icon: Icon(Icons.library_books), label: 'Biblioteca'),
        ],
      ),
    );
  }
}