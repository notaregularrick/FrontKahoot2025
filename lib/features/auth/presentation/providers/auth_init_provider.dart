import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart'; 

final authInitProvider = FutureProvider<void>((ref) async {
  try {
    final notifier = ref.read(authNotifierProvider.notifier);
    
    
    await Future.microtask(() async {
       await notifier.checkAuthStatus();
    });
    
  } catch (e) {
    print("Inicialización de sesión falló: $e");
  }
});