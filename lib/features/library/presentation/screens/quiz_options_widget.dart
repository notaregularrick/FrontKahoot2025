import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuizContextType { myCreations, favorites, inProgress, completed }

class QuizOptionsSheet extends ConsumerWidget {
  final QuizCardUiModel quiz;
  final QuizContextType type;

  const QuizOptionsSheet({super.key, required this.quiz, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              createEditButton(context),
              if (quiz.status != 'Borrador') ...[
                createPlayMultiplayerButton(context),
                createPlaySoloButton(context, ref),
              ],
            ],

            if (type == QuizContextType.favorites) ...[
              //3 puntos para descomponer el array
              createPlayMultiplayerButton(context),
              createPlaySoloButton(context, ref),
              createRemoveFavoriteButton(context, ref, quiz.id),
            ],

            if (type == QuizContextType.inProgress) ...[
              //3 puntos para descomponer el array
              createContinueButton(context),
              createPlayMultiplayerButton(context),
              createPlaySoloButton(context, ref),
            ],

            if (type == QuizContextType.completed) ...[
              //3 puntos para descomponer el array
              createWatchResultsButton(),
              createPlayMultiplayerButton(context),
              createPlaySoloButton(context, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget createEditButton(BuildContext context) {
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
        Navigator.pop(context);
        context.go('/create-kahoot/from-scratch?kid=${quiz.id}');
      },
    );
  }

  Widget createPlayMultiplayerButton(BuildContext context) {
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
        Navigator.pop(context);
        //context.go('/hostGame/${quiz.id}');
        context.go('/hostGame/14f5d158-fe86-4ba4-85cf-b83ce514c0bd');
      },
    );
  }

  Widget createPlaySoloButton(BuildContext context, WidgetRef ref) {
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
        Navigator.pop(context);
        // Navigate to the singleplayer orchestrator as a full-screen route and pass title
        final title = Uri.encodeComponent(quiz.title);
        context.go('/library/singleplayer/${quiz.id}?title=$title');
      },
    );
  }

  Widget createRemoveFavoriteButton(
    BuildContext context,
    WidgetRef ref,
    String quizId,
  ) {
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
        Navigator.pop(context);
        ref.read(asyncLibraryProvider.notifier).removeFavorite(quizId);
      },
    );
  }

  Widget createAddFavoriteButton(
    BuildContext context,
    WidgetRef ref,
    String quizId,
  ) {
    return ListTile(
      leading: Icon(Icons.favorite),
      title: Text(
        "Agregar a favoritos",
        style: TextStyle(
          //color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ref.read(asyncLibraryProvider.notifier).addFavorite(quizId);
      },
    );
  }

  Widget createContinueButton(BuildContext context) {
    return ListTile(
      leading: quiz.gameType == 'multiplayer'
          ? Icon(Icons.group)
          : Icon(Icons.gamepad),
      title: Text(
        quiz.gameType == 'multiplayer'
            ? "Continuar juego multijugador"
            : "Continuar juego en solitario",
        style: TextStyle(
          //color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      onTap: () async {
        // Continuar según el tipo y el id de juego (gameId)
        final type = (quiz.gameType ?? '').toLowerCase();
        // Intento almacenado localmente (por kahootId)
        final prefs = await SharedPreferences.getInstance();
        final storedAttemptId =
            prefs.getString('singleplayer_attempt_${quiz.id}') ?? '';
        final attemptId = quiz.gameId?.isNotEmpty == true
            ? quiz.gameId!
            : storedAttemptId;
        // Debug rápido para ver qué llega desde el backend en la UI
        // ignore: avoid_print
        print(
          '[in-progress][continue] type=${quiz.gameType} attemptId=$attemptId stored=$storedAttemptId quizId=${quiz.id}',
        );
        if (type == 'multiplayer') {
          Navigator.pop(context);
          context.go('/join');
          return;
        }
        // Default y singleplayer: si hay attemptId reanuda, si no, inicia uno nuevo
        final title = Uri.encodeComponent(quiz.title);
        Navigator.pop(context);
        if (attemptId.isNotEmpty) {
          context.go(
            '/library/singleplayer/${quiz.id}?attemptId=$attemptId&title=$title',
          );
        } else {
          context.go('/library/singleplayer/${quiz.id}?title=$title');
        }
      },
    );
  }

  Widget createWatchResultsButton() {
    return ListTile(
      leading: Icon(Icons.visibility),
      title: Text(
        quiz.gameType == 'multiplayer'
            ? "Ver resultados de juego multijugador"
            : "Ver resultados de juego en solitario",
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
