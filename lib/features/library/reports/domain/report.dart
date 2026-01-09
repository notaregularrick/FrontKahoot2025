import 'package:frontkahoot2526/features/library/reports/domain/player_ranking.dart';
import 'package:frontkahoot2526/features/library/reports/domain/question_analysis.dart';

//Informe de sesión
class Report {
  final String reportId;
  final String sessionId;
  final String title;
  final DateTime executionDate;
  final List<PlayerRanking> playerRanking;
  final List<Questionanalysis> questionAnalysis;

  const Report({
    required this.reportId,
    required this.sessionId,
    required this.title,
    required this.executionDate,
    required this.playerRanking,
    required this.questionAnalysis,
  });

  void orderRanking() {
    if (playerRanking.isEmpty) return;
    playerRanking.sort((a, b) => a.position.compareTo(b.position));
  }
}