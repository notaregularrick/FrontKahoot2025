import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/host_lobby.dart'; // Importa tu modelo PlayersInLobby
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';

class HostLobbyView extends StatelessWidget {
  final String quizTitle;
  final String coverImageUrl;
  final String pin;
  final List<PlayersInLobby> players;

  const HostLobbyView({
    super.key,
    required this.quizTitle,
    required this.coverImageUrl,
    required this.pin,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        100,
      ), // Padding abajo para no chocar con la barra
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TARJETA DE INFORMACIÓN DEL QUIZ
          _buildQuizInfoCard(),

          const SizedBox(height: 24),

          // 2. PIN DEL JUEGO
          _buildPinCard(context),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Jugadores en sala",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlueText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${players.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (players.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap:
                  true, // Importante porque está dentro de un ScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: players.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final player = players[index];
                return _buildPlayerCard(player, index);
              },
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
          // Imagen (si existe)
          if (coverImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 140,
                child: Image.network(
                  coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

          // Título
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              quizTitle.isEmpty ? "Cargando Quiz..." : quizTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlueText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: pin));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PIN copiado al portapapeles")),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.darkBlueText,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlueText.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "PIN DE ACCESO",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pin.isEmpty ? "..." : pin,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "(Toca para copiar)",
              style: TextStyle(color: Colors.white30, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayersInLobby player, int index) {
    // Generamos un color aleatorio estable basado en el índice
    final color = Colors.primaries[index % Colors.primaries.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              player.nickname.isNotEmpty
                  ? player.nickname[0].toUpperCase()
                  : "?",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              player.nickname,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Esperando a que se unan los jugadores...",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
