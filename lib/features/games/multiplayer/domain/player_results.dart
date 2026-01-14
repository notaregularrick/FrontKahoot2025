import 'package:frontkahoot2526/features/games/multiplayer/domain/game_progress.dart';

class PlayerResults {
  bool isCorrect;
  int pointsEarned;
  int totalScore;
  int rank;
  int previousRank;
  int streak;
  List<String> correctAnswerIds;
  String message;
  GameProgress progress;

  PlayerResults({
    required this.isCorrect,
    required this.pointsEarned,
    required this.totalScore,
    required this.rank,
    required this.previousRank,
    required this.streak,
    required this.correctAnswerIds,
    required this.message,
    required this.progress,
  });

  GameProgress getGameProgress() {
    return progress;
  }

  factory PlayerResults.fromJson(Map<String, dynamic> json) {
    // 1. Casteo seguro de primitivos
    bool correct = json['isCorrect'] as bool? ?? false;
    int pEarned = (json['pointsEarned'] as num?)?.toInt() ?? 0;
    int tScore = (json['totalScore'] as num?)?.toInt() ?? 0;
    int curRank = (json['rank'] as num?)?.toInt() ?? 0;
    int prevRank = (json['previousRank'] as num?)?.toInt() ?? 0;
    int curStreak = (json['streak'] as num?)?.toInt() ?? 0;
    String msg = json['message'] as String? ?? '';

    List<String> cAnswerIds =
        (json['correctAnswerIds'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    GameProgress prog = GameProgress.fromJson(
      (json['progress'] as Map<String, dynamic>?) ?? {},
    );

    return PlayerResults(
      isCorrect: correct,
      pointsEarned: pEarned,
      totalScore: tScore,
      rank: curRank,
      previousRank: prevRank,
      streak: curStreak,
      correctAnswerIds: cAnswerIds,
      message: msg,
      progress: prog,
    );
  }

  void logDebugInfo() {
    print('\n===== 📊 RESULTADOS DEL JUGADOR =====');
    print('✅ Correcto: $isCorrect');
    print('💰 Puntos Ganados: $pointsEarned');
    print('🏆 Puntaje Total: $totalScore');
    print('📈 Ranking: #$rank (Antes: #$previousRank)');
    print('🔥 Racha: $streak');
    print('💬 Mensaje: "$message"');
    for (var answerId in correctAnswerIds) {
      print('✔️ Respuesta Correcta ID: $answerId');
    }
    print(
      '🏁 Progreso: ${progress.currentQuestion}/${progress.totalQuestions}',
    );
    print('=====================================\n');
  }
}

void main(List<String> args) {
  final mockData = {
    "state": "results",
    "isCorrect": true,
    "pointsEarned": 932,
    "totalScore": 932,
    "rank": 1,
    "previousRank": 1,
    "streak": 1,
    "correctAnswerIds": ["0"],
    "message": "¡Estás cerca de la victoria!",
    "progress": {"current": 1, "total": 4},
  };

  PlayerResults results = PlayerResults.fromJson(
    mockData,
  );
  results.logDebugInfo();
}
