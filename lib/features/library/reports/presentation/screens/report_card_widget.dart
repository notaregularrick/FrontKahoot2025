import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';

class ReportCardWidget extends StatelessWidget {
  final Results result;
  final VoidCallback onTap;

  const ReportCardWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar color e ícono según tipo de juego
    final isMultiplayer = result.gameType != GameType.singleplayer;
    final iconColor = isMultiplayer ? Colors.purple : Colors.blue;
    final icon = isMultiplayer ? Icons.groups : Icons.person;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color.fromARGB(255, 86, 81, 81).withOpacity(0.3),
          width: 1,
        ),
      ),
      color: AppColors.orangeAccent.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlueText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          result.completationDateFormatted,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.darkBlueText.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          result
                              .gameType
                              .name, // "Singleplayer" o "Multiplayer"
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.darkBlueText.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (result.gameType == GameType.multiplayerPlayer)
                          Text(
                            "${result.finalScore} pts",
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors
                                  .darkBlueText, // Color de éxito para puntaje
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (result.rankingPosition != null)
                          Text(
                            "Puesto #${result.rankingPosition}",
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.darkBlueText.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right, color: Colors.blueGrey),
            ],
          ),
        ),
      ),
    );
  }
}
