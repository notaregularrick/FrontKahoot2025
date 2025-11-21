import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos el color de fondo para saber que estamos en nuestra pantalla
    final Color backgroundColor = Color(0xFFF5F5F5); // Tu Gris Claro
    final Color primaryColor = Color(0xFFF44336); // Tu Rojo Principal

    return Scaffold(
      // Usamos AppBar para poner el título
      appBar: AppBar(
        title: const Text("Mi Biblioteca"),
        backgroundColor: primaryColor, 
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡HOLA, EQUIPO! LA BIBLIOTECA FUNCIONA.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121), // Gris Oscuro
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Prueba exitosa en /library.',
              style: TextStyle(color: Color(0xFF757575)), // Gris Medio
            ),
          ],
        ),
      ),
    );
  }
}