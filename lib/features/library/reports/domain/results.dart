import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';

//H10.3
class Results{
  final String kahootId;
  final String gameId;
  final GameType gameType;
  final String title;
  final DateTime completionDate;
  final int finalScore;
  final int? rankingPosition;

  const Results({
    required this.kahootId,
    required this.gameId,
    required this.gameType,
    required this.title,
    required this.completionDate,
    required this.finalScore,
    this.rankingPosition,
  });

  String get completationDateFormatted {
    return '${completionDate.day}/${completionDate.month}/${completionDate.year}';
  }
}