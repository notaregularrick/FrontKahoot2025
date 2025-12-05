import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),  // Título de la aplicación
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título de la página
            const Text(
              'Bienvenido a la aplicación',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Botón para Iniciar Sesión
            ElevatedButton(
              onPressed: () {
                context.push('/login');  // Navega a la pantalla de login
              },
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 20),

            // Botón para Registrarse
            ElevatedButton(
              onPressed: () {
                context.push('/register');  // Navega a la pantalla de registro
              },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
