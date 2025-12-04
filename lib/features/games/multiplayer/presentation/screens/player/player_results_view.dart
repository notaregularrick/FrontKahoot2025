// import 'package:flutter/material.dart';
// import 'package:frontkahoot2526/features/games/multiplayer/domain/individual_scoreboard.dart';
// import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/individual_scoreboard.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class PlayerResultsView extends StatefulWidget {
  final bool isCorrect;
  final int pointsEarned;
  final String? correctAnswerText;
  final List<IndividualScoreboard> scoreboard;
  final String myPlayerId;

  const PlayerResultsView({
    super.key,
    required this.isCorrect,
    required this.pointsEarned,
    this.correctAnswerText,
    required this.scoreboard,
    required this.myPlayerId,
  });

  @override
  State<PlayerResultsView> createState() => _PlayerResultsViewState();
}

class _PlayerResultsViewState extends State<PlayerResultsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), //500 ms para entrar/salir
      vsync: this,
    );

    _offsetAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, -1.0), //Empieza arriba
          end: Offset.zero, //termina donde va
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack, //efecto para entrar
            reverseCurve: Curves.easeIn, //efecto para salir
          ),
        );

    //Secuencia de entrar/salir
    _playNotificationSequence();
  }

  void _playNotificationSequence() async {
    try {
      await _controller.forward(); //baja

      await Future.delayed(const Duration(seconds: 2)); //da chance a leer

      //sube
      if (mounted) {
        await _controller.reverse();
      }
    } catch (e) {
      //Futuro manejo de errores
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            if (widget.correctAnswerText != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "La respuesta correcta era:",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.correctAnswerText!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Título marcador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Marcador Global",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueText,
                  ),
                ),
              ),
            ),

            // Lista de jugadores
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.scoreboard.length,
                itemBuilder: (context, index) {
                  final entry = widget.scoreboard[index];
                  // Comparación por Nickname o ID ya que aún no sé cómo lo hará el back
                  final isMe =
                      entry.nickname == widget.myPlayerId ||
                      entry.playerId == widget.myPlayerId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.mustardYellow.withValues(alpha: 0.3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isMe
                          ? Border.all(color: AppColors.mustardYellow, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isMe
                            ? AppColors.mustardYellow
                            : Colors.grey.shade200,
                        child: Text(
                          "#${entry.rank}",
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        entry.nickname,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.black : Colors.black87,
                        ),
                      ),
                      trailing: Text(
                        "${entry.score}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        //Notificación de Correcto/Incorrecto
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _offsetAnimation,
            child: _FeedbackBanner(
              isCorrect: widget.isCorrect,
              points: widget.pointsEarned,
              correctText: widget.correctAnswerText,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final int points;
  final String? correctText;

  const _FeedbackBanner({
    required this.isCorrect,
    required this.points,
    this.correctText,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.red;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final title = isCorrect ? "¡Correcto!" : "Incorrecto";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Padding
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          if (isCorrect)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "+ $points pts",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
