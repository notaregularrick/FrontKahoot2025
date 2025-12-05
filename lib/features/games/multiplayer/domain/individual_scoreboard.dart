class IndividualScoreboard {
  final String playerId;
  final String nickname;
  final int score;
  final int rank;
  final int? previousRank;   // Opcional (resultados de pregunta anterior)
  final int? correctCount;   // Opcional (podio final)
  final int? incorrectCount; // Opcional (podio final)

  const IndividualScoreboard({
    required this.playerId,
    required this.nickname,
    required this.score,
    required this.rank,
    this.previousRank,
    this.correctCount,
    this.incorrectCount,
  });
}