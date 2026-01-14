import 'package:frontkahoot2526/features/games/multiplayer/domain/player_leaderboard.dart';

class HostEndGame {
  int totalPlayers;
  List<PlayerLeaderboard> podium;

  HostEndGame({required this.totalPlayers, required this.podium});

  factory HostEndGame.fromJson(Map<String, dynamic> json) {
    int total = (json['totalParticipants'] as num?)?.toInt() ?? 0;

    List<PlayerLeaderboard> podiumList =
        (json['finalPodium'] as List?)
            ?.map((e) => PlayerLeaderboard.fromJson(e))
            .toList() ??
        [];

    podiumList.sort((a, b) => a.rank.compareTo(b.rank));

    return HostEndGame(totalPlayers: total, podium: podiumList);
  }

  void logDebugInfo() {
    print('\n===== 🏁 HOST END GAME DEBUG =====');
    print('👥 Total Participantes: $totalPlayers');
    print('🏆 PODIO FINAL (Ordenado):');

    if (podium.isEmpty) {
      print('   ⚠️ El podio está vacío');
    } else {
      for (var player in podium) {
        String medal = '';
        if (player.rank == 1)
          medal = '🥇';
        else if (player.rank == 2)
          medal = '🥈';
        else if (player.rank == 3)
          medal = '🥉';

        print(
          '   $medal Rank #${player.rank}: ${player.nickname} (${player.score} pts)',
        );
      }
    }
    print('==================================\n');
  }
}

void main(List<String> args) {
  // final mockedData = {
  //   "state": "end",
  //   "finalPodium": [
  //     {
  //       "playerId": "a25c1189-d3c0-4990-8e30-e5f5603c202c",
  //       "nickname": "Carlitos",
  //       "score": 1419,
  //       "rank": 1,
  //       "previousRank": 1,
  //     },
  //   ],
  //   "winner": {
  //     "playerId": "a25c1189-d3c0-4990-8e30-e5f5603c202c",
  //     "nickname": "Carlitos",
  //     "score": 1419,
  //     "rank": 1,
  //     "previousRank": 1,
  //   },
  //   "totalParticipants": 1,
  // };

  final mockedData2 = {
    "state": "end",
    "finalPodium": [
      {
        "playerId": "uuid",
        "nickname": "Player1",
        "score": 1000,
        "rank": 2,
        "previousRank": 1,
      },
      {
        "playerId": "uuid",
        "nickname": "Player2",
        "score": 1100,
        "rank": 1,
        "previousRank": 2,
      },
      {
        "playerId": "uuid",
        "nickname": "Player3",
        "score": 500,
        "rank": 3,
        "previousRank": 3,
      },
    ],
    "winner": {
      "playerId": "897115b0-e3ff-4448-ac06-58584df826ea",
      "nickname": "Player1",
      "score": 1,
      "rank": 1,
      "previousRank": 1,
    },
    "totalParticipants": 3,
  };

  final endGame = HostEndGame.fromJson(mockedData2);
  endGame.logDebugInfo();
}
