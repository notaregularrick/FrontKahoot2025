import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/router.dart'; // Verifica esta ruta
import 'features/auth/presentation/providers/auth_init_provider.dart';

void main() async {
  // Asegura que el motor de Flutter esté listo antes de cualquier cosa
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. CORRECCIÓN CRÍTICA: Usamos ref.watch, no ref.read
    // Esto hace que la pantalla se actualice cuando termine la carga.
    final authInit = ref.watch(authInitProvider);

    return authInit.when(
      // A. ESTADO DE CARGA (Splash Screen temporal)
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Iniciando sesión...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
      
      // B. ESTADO DE ERROR (Para que sepas qué pasó si falla)
      error: (error, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  const Text("Error al iniciar la app:"),
                  const SizedBox(height: 10),
                  Text(error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Intenta recargar el provider si falló
                      ref.invalidate(authInitProvider);
                    },
                    child: const Text("Reintentar"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),

      // C. ESTADO DE ÉXITO (Arranca la app real)
      data: (_) {
        // Obtenemos el router solo cuando estamos listos
        final router = ref.watch(appRouterProvider);
        
        return MaterialApp.router(
          title: 'Quiz App',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}