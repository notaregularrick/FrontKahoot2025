import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/quiz_card_widget.dart';

class QuizCardPreviewScreen extends StatelessWidget {
  const QuizCardPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de prueba (Mock Data)
    final quizNormal = QuizCardUiModel(
      id: '1',
      title: 'Historia de Venezuela',
      imageUrl: 'https://via.placeholder.com/150',
      questionCount: '15 Qs',
      dateInfo: '29 Nov',
      playCount: '150 plays',
      visibilityText: 'Public',
      visibilityIcon: Icons.public,
      authorName: null, // Simulando "Mis Creaciones"
    );
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Tu fondo gris suave
      appBar: AppBar(title: const Text("Prueba de Diseño")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("1. Estilo 'Mis Creaciones' (Normal)", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          QuizCard(quiz: quizNormal),
          
          const SizedBox(height: 30),
          
          const Text("2. Estilo 'Favoritos' (Textos Largos)", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}