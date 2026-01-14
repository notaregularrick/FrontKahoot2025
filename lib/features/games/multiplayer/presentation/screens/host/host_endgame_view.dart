import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/host_end_game.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player_leaderboard.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class HostEndGameView extends StatelessWidget {
  final HostEndGame endGame;
  final String quizTitle;
  final String coverImageUrl;

  const HostEndGameView({
    super.key,
    required this.endGame,
    required this.quizTitle,
    required this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final top3 = endGame.podium.take(3).toList();

    PlayerLeaderboard? first, second, third;
    if (top3.isNotEmpty) first = top3[0]; // Rank 1
    if (top3.length > 1) second = top3[1]; // Rank 2
    if (top3.length > 2) third = top3[2]; // Rank 3

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuizInfoCard(),

          const SizedBox(height: 30),

          const Text(
            "🏆 PODIO FINAL 🏆",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlueText,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          if (first == null)
            const Center(child: Text("No hubo participantes"))
          else
            SizedBox(
              height: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (second != null)
                    Expanded(
                      child: _PodiumBar(
                        player: second,
                        color: Colors.grey.shade400, 
                        heightPercentage: 0.65,
                        icon: Icons.looks_two,
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _PodiumBar(
                      player: first,
                      color: const Color(0xFFFFD700), 
                      heightPercentage: 0.85,
                      isWinner: true,
                      icon: Icons.emoji_events,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 🥉 3ER LUGAR (Derecha)
                  if (third != null)
                    Expanded(
                      child: _PodiumBar(
                        player: third,
                        color: const Color(0xFFCD7F32), 
                        heightPercentage: 0.50,
                        icon: Icons.looks_3,
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),
            ),

          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Total de jugadores",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.groups,
                      color: AppColors.primaryRed,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${endGame.totalPlayers}",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (coverImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 120,
                child: Image.network(
                  coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              quizTitle.isEmpty ? "Juego Finalizado" : quizTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlueText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumBar extends StatelessWidget {
  final PlayerLeaderboard player;
  final Color color;
  final double heightPercentage;
  final bool isWinner;
  final IconData icon;

  const _PodiumBar({
    required this.player,
    required this.color,
    required this.heightPercentage,
    required this.icon,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: isWinner ? 30 : 22,
          child: Icon(icon, color: Colors.black54, size: isWinner ? 30 : 20),
        ),
        const SizedBox(height: 8),

        Text(
          player.nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isWinner ? 19 : 14,
            color: AppColors.darkBlueText,
          ),
        ),

        Text(
          "${player.score} pts",
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),

        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              height: 200 * heightPercentage,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                "#${player.rank}",
                style: TextStyle(
                  fontSize: isWinner ? 40 : 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
