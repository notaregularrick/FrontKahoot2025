import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontkahoot2526/core/navigation/router.dart';
import 'features/auth/presentation/providers/auth_init_provider.dart'; // El nuevo import

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de cualquier código asincrónico.

  // Inicializar Firebase
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Suscribirse a la inicialización del token desde SecureStorage
    // Usar `watch` para que el widget se reconstruya cuando la inicialización termine.
    final authInit = ref.watch(authInitProvider);

    var messaging = FirebaseMessaging.instance;
    messaging.requestPermission(alert: true, badge: true, sound: true).then((
      value,
    ) {
      print('Permission granted: ${value.authorizationStatus}');
    });

    return authInit.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => const MaterialApp(
        home: Scaffold(body: Center(child: Text("Error loading session"))),
      ),
      data: (_) => MaterialApp.router(
        title: 'Quiz App',
        debugShowCheckedModeBanner: false,
        routerConfig: ref.watch(appRouterProvider),
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
      ),
    );
  }
}
