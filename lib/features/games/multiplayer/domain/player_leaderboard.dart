class PlayerLeaderboard {
  String playerId;
  String nickname;
  int score;
  int rank;
  int previousRank;

  PlayerLeaderboard({
    required this.playerId,
    required this.nickname,
    required this.score,
    required this.rank,
    required this.previousRank,
  });

  factory PlayerLeaderboard.fromJson(Map<String, dynamic> json) {
    return PlayerLeaderboard(
      playerId: json['playerId'] ?? '',
      nickname: json['nickname'] ?? 'Jugador',
      score: (json['score'] as num).toInt(),
      rank: (json['rank'] as num).toInt(),
      previousRank: (json['previousRank'] as num).toInt(),
    );
  }
}
