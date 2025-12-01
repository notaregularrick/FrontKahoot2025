import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/router.dart';
import 'features/auth/application/state/auth_init_provider.dart'; // El nuevo import

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de cualquier código asincrónico.

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
    // Leer la inicialización del token desde SecureStorage
    final authInit = ref.watch(authInitProvider);

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
