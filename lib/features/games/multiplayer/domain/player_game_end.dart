class PlayerGameEnd {
  int rank;
  int totalScore;
  bool isPodium;
  bool isWinner;
  int finalStreak;

  PlayerGameEnd({
    required this.rank,
    required this.totalScore,
    required this.isPodium,
    required this.isWinner,
    required this.finalStreak,
  });

  factory PlayerGameEnd.fromJson(Map<String, dynamic> json) {
    int pRank = (json['rank'] as num?)?.toInt() ?? 0;
    int tScore = (json['totalScore'] as num?)?.toInt() ?? 0;

    bool podium = json['isPodium'] as bool? ?? false;
    bool winner = json['isWinner'] as bool? ?? false;

    int pStreak = (json['finalStreak'] as num?)?.toInt() ?? 0;

    return PlayerGameEnd(
      rank: pRank,
      totalScore: tScore,
      isPodium: podium,
      isWinner: winner,
      finalStreak: pStreak,
    );
  }

  void logDebugInfo() {
    print('\n===== 🏁 FIN DEL JUEGO =====');
    print('🏅 Posición Final: #$rank');
    print('💰 Puntaje Final: $totalScore');
    print('🏆 ¿Está en Podio?: ${isPodium ? "SÍ" : "NO"}');
    print('👑 ¿Es Ganador?: ${isWinner ? "¡SÍ, FELICIDADES!" : "No"}');
    print('🔥 Racha Final: $finalStreak');
    print('============================\n');
  }
}

void main(List<String> args) {
  final mockData = {
    "state": "end",
    "rank": 1,
    "totalScore": 1419,
    "isPodium": true,
    "isWinner": true,
    "finalStreak": 1,
  };
  PlayerGameEnd gameEnd = PlayerGameEnd.fromJson(
    mockData,
  );
  gameEnd.logDebugInfo();
}
