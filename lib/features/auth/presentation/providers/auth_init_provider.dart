import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart'; 

final authInitProvider = FutureProvider<void>((ref) async {
  try {
    final notifier = ref.read(authNotifierProvider.notifier);
    
    // CORRECCIÓN: Esperamos un microtask para salir del ciclo de construcción actual
    // antes de modificar otro provider.
    await Future.microtask(() async {
       await notifier.checkAuthStatus();
    });
    
  } catch (e) {
    // Si falla, lo ignoramos para que la app arranque en modo "No logueado"
    print("Inicialización de sesión falló: $e");
  }
});