import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class PlayerLobbyView extends StatelessWidget {
  final String quizTitle;
  final String? quizImageUrl;
  final String gamePin;
  final List<Player> players;
  final String myPlayerId; // Para resaltar mi nombre

  const PlayerLobbyView({
    super.key,
    required this.quizTitle,
    this.quizImageUrl,
    required this.gamePin,
    required this.players,
    required this.myPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Tarjeta con info del quiz
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              //Imagen del quiz
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: quizImageUrl != null
                      ? Image.network(quizImageUrl!, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 16),

              // Título del quiz
              Text(
                quizTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              //Jugadores
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${players.length} jugadores conectados",
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        //Lista de jugadores
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas de nombres
                childAspectRatio: 3.5, // Proporción rectangular
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final isMe = player.nickname == myPlayerId;

                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.mustardYellow : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMe ? Colors.orange : Colors.grey.shade300,
                      width: isMe ? 2 : 1,
                    ),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 2,
                        ),
                    ],
                  ),
                  child: Text(
                    player.nickname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.black : Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ),

        //Estado y pin
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          color: AppColors.primaryRed,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mensaje de estado
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Esperando al anfitrión...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "¡Prepárate!",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // PIN de la sala
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "PIN",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        gamePin,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
