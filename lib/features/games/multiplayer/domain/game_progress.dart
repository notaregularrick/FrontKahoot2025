class GameProgress {
  int currentQuestion;
  int totalQuestions;

  GameProgress({
    required this.currentQuestion,
    required this.totalQuestions,
  });

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    int current = (json['current'] as num?)?.toInt() ?? 0;
    int total = (json['total'] as num?)?.toInt() ?? 0;

    return GameProgress(
      currentQuestion: current,
      totalQuestions: total,
    );
  }
}

