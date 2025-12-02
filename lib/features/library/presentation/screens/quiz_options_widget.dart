import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';

enum QuizContextType { myCreations, favorites, inProgress }

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
      child: SingleChildScrollView(
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

            Container(
              height: 150,
              width: double.infinity, 
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  quiz.imageUrl,
                  fit: BoxFit.cover,
                  
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },

                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. Info Básica (Lo que pediste)
            Text(
              quiz.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30),

            // 3. Botones Dinámicos según la Sección
            if (type == QuizContextType.myCreations) ...[
              //3 puntos para descomponer el array
              createEditButton(),
              createPlayMultiplayerButton(),
              createPlaySoloButton(),
            ],

            if (type == QuizContextType.favorites) ...[
              //3 puntos para descomponer el array
              createPlayMultiplayerButton(),
              createPlaySoloButton(),
              createDeleteFavoriteButton(),
            ],

            if (type == QuizContextType.inProgress) ...[
              //3 puntos para descomponer el array
              createContinueButton(),
            ],
          ],
        ),
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

  Widget createPlaySoloButton() {
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

  Widget createDeleteFavoriteButton() {
    return ListTile(
      leading: Icon(Icons.delete),
      title: Text(
        "Eliminar de favoritos",
        style: TextStyle(
          //color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      onTap: () {
        //Elimina el quiz de favoritos
      },
    );
  }

  Widget createContinueButton() {
    return ListTile(
      leading: quiz.gameType == 'multiplayer' ? Icon(Icons.group) : Icon(Icons.gamepad),
      title: Text(
        quiz.gameType == 'multiplayer' ? "Continuar juego multijugador" : "Continuar juego en solitario",
        style: TextStyle(
          //color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      onTap: () {
        //Llama para continuar un juego en progreso
      },
    );
  }
}

