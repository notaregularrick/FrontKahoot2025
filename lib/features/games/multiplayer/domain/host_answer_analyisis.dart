class AnswerAnalysis {
  String answerId;
  String? answerText;
  String? answerImageUrl;
  int selectedCount;
  bool isCorrect;

  AnswerAnalysis({
    required this.answerId,
    this.answerText,
    this.answerImageUrl,
    required this.selectedCount,
    required this.isCorrect,
  });
}