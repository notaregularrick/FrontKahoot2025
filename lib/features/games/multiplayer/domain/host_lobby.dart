class HostLobby {
  List<PlayersInLobby> players;
  int totalPlayers;
  HostLobby({required this.players, required this.totalPlayers});

  factory HostLobby.fromJson(Map<String, dynamic> json) {
    return HostLobby(
      players:
          (json['players'] as List?)
              ?.map((e) => PlayersInLobby.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      totalPlayers: (json['numberOfPlayers'] as num?)?.toInt() ?? 0,
    );
  }
  void logDebugInfo() {
    print('\n===== 🏠 HOST LOBBY DEBUG =====');
    print('🔢 Contador del servidor: $totalPlayers');
    print('📋 Lista real en memoria: ${players.length} jugadores');

    if (players.isEmpty) {
      print('   ⚠️ La sala está vacía (Esperando jugadores...)');
    } else {
      for (int i = 0; i < players.length; i++) {
        final p = players[i];
        print('   👤 [${i + 1}] ${p.nickname} (ID: ${p.playerId})');
      }
    }
    print('===============================\n');
  }
}

class PlayersInLobby {
  String playerId;
  String nickname;
  PlayersInLobby({required this.playerId, required this.nickname});
  factory PlayersInLobby.fromJson(Map<String, dynamic> json) {
    return PlayersInLobby(
      playerId: json['playerId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? 'Jugador',
    );
  }
}

void main(List<String> args) {
  final mockedData = {
  "state": "lobby",
   "players": [
     {
        "playerId": "ideplayer1",
        "nickname": "Player 1"
     },
    {
        "playerId": "ideplayer2",
        "nickname": "Player 2"
     }
    ],
    "numberOfPlayers": 2
}
;

  final lobby = HostLobby.fromJson(mockedData);
  lobby.logDebugInfo();
}
