import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/host_answer_analyisis.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/host_results.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player_leaderboard.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class HostResultsView extends StatelessWidget {
  final HostResults results;

  const HostResultsView({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    // Tomamos solo el Top 5 para no llenar la pantalla si hay muchos jugadores
    final topPlayers = results.leaderboard.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        100,
      ), // Espacio para la barra inferior
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- SECCIÓN 1: LEADERBOARD ---
          const Text(
            "Marcador (Top 5)",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 16),

          if (topPlayers.isEmpty)
            _buildEmptyState("Aún no hay puntajes")
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topPlayers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _LeaderboardCard(player: topPlayers[index]);
              },
            ),

          const SizedBox(height: 40),
          const Divider(thickness: 2),
          const SizedBox(height: 20),

          const Text(
            "Estadísticas de las respuestas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 16),

          if (results.answerAnalysis.isEmpty)
            _buildEmptyState("No hay datos de análisis")
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.answerAnalysis.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _AnalysisCard(analysis: results.answerAnalysis[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
      ),
    );
  }
}

// -----------------------------------------------------------
// WIDGET INTERNO: TARJETA DE JUGADOR (LEADERBOARD)
// -----------------------------------------------------------
class _LeaderboardCard extends StatelessWidget {
  final PlayerLeaderboard player; //

  const _LeaderboardCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final isFirst = player.rank == 1;

    // Si es primero: Amarillo mostaza. Si no: Blanco.
    final backgroundColor = isFirst ? AppColors.mustardYellow : Colors.white;
    final textColor = isFirst ? Colors.black : Colors.black87;
    final borderColor = isFirst ? Colors.orangeAccent : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isFirst ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // RANGO (#1, #2...)
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFirst
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(
              "#${player.rank}",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          const SizedBox(width: 16),

          // NICKNAME
          Expanded(
            child: Text(
              player.nickname,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          // PUNTAJE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${player.score}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              Text(
                "pts",
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------
// WIDGET INTERNO: TARJETA DE ANÁLISIS (ESTADÍSTICAS)
// -----------------------------------------------------------
class _AnalysisCard extends StatelessWidget {
  final AnswerAnalysis analysis; //

  const _AnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final isCorrect = analysis.isCorrect;

    // Verde si es correcta, Rojo suave si es incorrecta
    final borderColor = isCorrect ? Colors.green : Colors.red.shade100;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final iconColor = isCorrect ? Colors.green : Colors.red.shade200;

    final hasImage =
        analysis.answerImageUrl != null && analysis.answerImageUrl!.isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          // 1. CONTENIDO VISUAL (TEXTO O IMAGEN)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              // Si tiene imagen, mostramos una miniatura a la izquierda
              child: hasImage
                  ? Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            analysis.answerImageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Si hay imagen Y texto, mostramos el texto al lado
                        if (analysis.answerText != null)
                          Expanded(
                            child: Text(
                              analysis.answerText!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    )
                  // Si solo es texto
                  : Text(
                      analysis.answerText ?? "Opción sin texto",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // 2. ESTADÍSTICAS Y VALIDACIÓN (DERECHA)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(height: 4),

                // Contador de votos
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "${analysis.selectedCount}", //
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
