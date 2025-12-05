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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título de la página
              const Text(
                'Bienvenido a la aplicación',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Botón para Iniciar Sesión (centrado, ancho fijo para consistencia)
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/login'); // Navega a la pantalla de login
                  },
                  child: const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 16),

              // Botón para Registrarse
              SizedBox(
                width: 220,
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/register'); // Navega a la pantalla de registro
                  },
                  child: const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
