import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/individual_scoreboard.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:go_router/go_router.dart';

class PlayerGameEndView extends StatelessWidget {
  final List<IndividualScoreboard> finalScoreboard;
  final String myPlayerId;
  final String winnerNickname;

  const PlayerGameEndView({
    super.key,
    required this.finalScoreboard,
    required this.myPlayerId,
    required this.winnerNickname,
  });

  @override
  Widget build(BuildContext context) {
    //Seleccionar jugadores del podio
    final top3 = finalScoreboard.take(3).toList();
    final restOfPlayers = finalScoreboard.length > 3
        ? finalScoreboard.sublist(3)
        : <IndividualScoreboard>[];

    IndividualScoreboard? first, second, third;
    if (top3.isNotEmpty) first = top3[0];
    if (top3.length > 1) second = top3[1];
    if (top3.length > 2) third = top3[2];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Podio Final",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkBlueText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Volver a la pantalla con la barra de navegación y la sección 'Unirse'
            context.go('/join');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //2do lugar a la izquierda
                  if (second != null)
                    Expanded(
                      child: _PodiumBar(
                        entry: second,
                        position: 2,
                        heightFactor: 0.65,
                        color: Colors.grey.shade400, // Plata
                        fontColor: AppColors.darkBlueText,
                      ),
                    ),

                  //1er lugar en el centro
                  if (first != null)
                    Expanded(
                      child: _PodiumBar(
                        entry: first,
                        position: 1,
                        heightFactor: 0.85,
                        color: AppColors.mustardYellow, // Oro
                        fontColor: AppColors.darkBlueText,
                        isWinner: true,
                      ),
                    ),

                  //3er lugar a la derecha
                  if (third != null)
                    Expanded(
                      child: _PodiumBar(
                        entry: third,
                        position: 3,
                        heightFactor: 0.50,
                        color: AppColors.orangeAccent, // Bronce
                        fontColor: AppColors.darkBlueText,
                      ),
                    ),
                ],
              ),
            ),
          ),

          //Resto de los jugadores
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Lista
                  Expanded(
                    child: restOfPlayers.isEmpty
                        ? Center(
                            child: Text(
                              "No hay más jugadores",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: restOfPlayers.length,
                            itemBuilder: (context, index) {
                              final player = restOfPlayers[index];
                              final isMe =
                                  player.nickname == myPlayerId ||
                                  player.playerId == myPlayerId;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.mustardYellow.withValues(
                                          alpha: 0.2,
                                        )
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: isMe
                                      ? Border.all(
                                          color: AppColors.mustardYellow,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    child: Text(
                                      "#${player.rank}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    player.nickname,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isMe
                                          ? AppColors.primaryRed
                                          : AppColors.darkBlueText,
                                    ),
                                  ),
                                  trailing: Text(
                                    "${player.score} pts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBlueText.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          //Botón para salir (alineado a la izquierda como en otras pantallas)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 140, maxWidth: 260, minHeight: 48),
                child: ElevatedButton(
                  onPressed: () {
                    // Ir a la pantalla 'Unirse' y mostrar la navbar
                    context.go('/join');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Text(
                      "Salir del Juego",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Barra del podio individual
class _PodiumBar extends StatelessWidget {
  final IndividualScoreboard entry;
  final int position;
  final double heightFactor;
  final Color color;
  final Color fontColor;
  final bool isWinner;

  const _PodiumBar({
    required this.entry,
    required this.position,
    required this.heightFactor,
    required this.color,
    required this.fontColor,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Corona para el ganador (Opcional)
        if (isWinner)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          ),

        // Nombre y Puntos
        Text(
          entry.nickname,
          style: TextStyle(
            color: fontColor,
            fontWeight: FontWeight.bold,
            fontSize: isWinner ? 18 : 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            "${entry.score}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fontColor.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // La Barra
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              // Altura relativa + un mínimo para que no desaparezca
              height: (220 * heightFactor).clamp(50.0, 250.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                "$position",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isWinner ? 60 : 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
