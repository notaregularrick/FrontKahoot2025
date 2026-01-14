import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/game_progress.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/host_answer_analyisis.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/player_leaderboard.dart';

class HostResults {
  List<PlayerLeaderboard> leaderboard;
  List<AnswerAnalysis> answerAnalysis;
  GameProgress progress;

  HostResults({
    required this.leaderboard,
    required this.progress,
    this.answerAnalysis = const [],
  });

  factory HostResults.fromJson(
    Map<String, dynamic> json, {
    List<QuestionAnswers>? options,
  }) {
    final progressObj = GameProgress.fromJson(
      json['progress'] as Map<String, dynamic>,
    );

    final leaderboardList =
        (json['leaderboard'] as List?)
            ?.map((e) => PlayerLeaderboard.fromJson(e))
            .toList() ??
        [];

    List<AnswerAnalysis> analysisList = [];

    final stats = json['stats'] as Map<String, dynamic>?;
    final distribution = stats?['distribution'] as Map<String, dynamic>? ?? {};
    final correctIds = List<String>.from(json['correctAnswerId'] ?? []);

    if (options != null && options.isNotEmpty) {
      // Si nos pasaron las opciones, las usamos para enriquecer la data
      analysisList = options.map((option) {
        final id = option.answerIndex; // "0", "1", etc.
        // Buscamos cuántos votaron por esta opción en el mapa de distribución
        final count = (distribution[id] as num?)?.toInt() ?? 0;
        final isCorrect = correctIds.contains(id);

        return AnswerAnalysis(
          answerId: id,
          answerText: option.answerText, //
          answerImageUrl: option.answerImageUrl, //
          selectedCount: count,
          isCorrect: isCorrect,
        );
      }).toList();
    } else {
      // Fallback por si no llegan opciones (solo mostramos IDs)
      distribution.forEach((key, value) {
        analysisList.add(
          AnswerAnalysis(
            answerId: key,
            selectedCount: (value as num).toInt(),
            isCorrect: correctIds.contains(key),
            answerText: null,
            answerImageUrl: null,
          ),
        );
      });
    }

    return HostResults(
      leaderboard: leaderboardList,
      progress: progressObj,
      answerAnalysis: analysisList,
    );
  }

  GameProgress getGameProgress() {
    return progress;
  }

  void logDebugInfo() {
    print('\n===== 📊 HOST RESULTS DEBUG =====');

    // 1. Imprimir Progreso
    print('🔄 PROGRESO DE JUEGO:');
    print(
      '   🔹 Slide: ${progress.currentQuestion} / ${progress.totalQuestions}',
    );
    print('');

    // 2. Imprimir Leaderboard
    print('🏆 LEADERBOARD (${leaderboard.length} jugadores):');
    if (leaderboard.isEmpty) {
      print('   ⚠️ No hay jugadores en el leaderboard');
    } else {
      for (var player in leaderboard) {
        // Asumiendo que PlayersLeaderboard tiene rank, nickname, score, etc.

        print(
          '   #${player.rank} ${player.nickname} - Pts: ${player.score} (Prev: ${player.previousRank})',
        );
      }
    }
    print('');

    // 3. Imprimir Análisis de Respuestas
    print('📊 ANÁLISIS DE RESPUESTAS:');
    if (answerAnalysis.isEmpty) {
      print('   ⚠️ No hay datos de análisis');
    } else {
      for (var analysis in answerAnalysis) {
        final statusIcon = analysis.isCorrect ? '✅' : '❌';
        final text = analysis.answerText ?? "Sin texto (Solo ID)";
        final img = analysis.answerImageUrl != null ? "🖼️ Tiene imagen" : "no imagen";

        print(
          '   $statusIcon [ID: ${analysis.answerId}] Votos: ${analysis.selectedCount} | "$text" $img',
        );
      }
    }
    print('===================================\n');
  }
}

// void main(List<String> args) {
//   final mockedData = {
//     "state": "results",
//     "correctAnswerId": ["0"],
//     "leaderboard": [
//       {
//         "playerId": "00f79ad1-d8c7-4096-95ed-198935d912e7",
//         "nickname": "Carlitos",
//         "score": 932,
//         "rank": 1,
//         "previousRank": 1,
//       },
//     ],
//     "stats": {
//       "totalAnswers": 0,
//       "distribution": {"0": 0, "1": 0},
//     },
//     "progress": {"current": 2, "total": 4, "isLastSlide": false},
//   };
//   final List<QuestionAnswers> options = [
//     QuestionAnswers(answerIndex: "0", answerImageUrl: "imagen",),
//     QuestionAnswers(answerIndex: "1", answerText: "Opción B"),
//   ];
//   final results = HostResults.fromJson(mockedData, options: options);
//   results.logDebugInfo();
// }
