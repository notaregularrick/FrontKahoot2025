import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/navigation/router.dart';



void main() {
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
    // configuración del router
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      
      routerConfig: appRouter,
      
      //Tema global que luego se puede personalizar (por ejemplo con archivo en core)
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
  }
}