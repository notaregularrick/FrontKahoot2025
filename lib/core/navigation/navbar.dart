import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          if (index == 2) {
            if (context.mounted) {
              context.push('/profile');        // navega
            }

            return; 
          }
          if (index == 3) {
            final notifier = ref.read(authNotifierProvider.notifier);

            await notifier.logout();

            WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/inicio');  // Navega a la página de inicio después de hacer logout
            }
          });      // navega sin dejar rastro
            

            return; 
          }
          
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex, //Eso hace que al volver por ejemplo a bilblioteca, vuelva a donde estaba y no a biblioteca principal
          );
        },
        destinations: const [
          //Los íconos que aparecerán en la barra de navegación.
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          NavigationDestination(icon: Icon(Icons.person_2), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.arrow_circle_left), label: 'Cerrar Sesión'),
        ],
      ),
    );
  }
}