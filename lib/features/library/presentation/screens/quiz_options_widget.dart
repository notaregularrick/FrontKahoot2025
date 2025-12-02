import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';

enum QuizContextType { myCreations, favorites }

class QuizOptionsSheet extends StatelessWidget {
  final QuizCardUiModel quiz;
  final QuizContextType type;

  const QuizOptionsSheet({super.key, required this.quiz, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ocupa solo lo necesario
        children: [
          // 1. La "Barrita" para arrastrar (Visual cue)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 2. Info Básica (Lo que pediste)
          Text(
            quiz.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "ID: ${quiz.id}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 30),

          // 3. Botones Dinámicos según la Sección
          if (type == QuizContextType.myCreations) ...[//3 puntos para descomponer el array
            createEditButton(),
            createPlayMultiplayerButton(),
            createPlaySoloButton(),
          ],

        ],
      ),
    );
  }

  Widget createEditButton() {
    return ListTile(
      leading: Icon(Icons.edit),
      title: Text(
        "Editar",
        style: TextStyle(
          //color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      onTap: () {
        //Lleva a la pestaña de editar
      },
    );
  }

  Widget createPlayMultiplayerButton() {
    return ListTile(
      leading: Icon(Icons.group),
      title: Text(
        "Jugar multijugador",
        style: TextStyle(
          //color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      onTap: () {
        //Lleva a la pestaña de juego sincrono
      },
    );
  }

  Widget createPlaySoloButton(){
    return ListTile(
      leading: Icon(Icons.gamepad),
      title: Text(
        "Jugar en solitario",
        style: TextStyle(
          //color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      onTap: () {
        //Lleva a la pestaña de juego solitario
      },
    );
  }

}
