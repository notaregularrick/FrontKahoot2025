class PersonalQuestionResult {
  final int questionIndex;
  final String questionText;
  final bool isCorrect;
  final List<String> answerText;
  final List<String> answerMediaId;
  final num timeTakenMs;

  const PersonalQuestionResult({
    required this.questionIndex,
    required this.questionText,
    required this.isCorrect,
    required this.answerText,
    required this.answerMediaId,
    required this.timeTakenMs,
  });
}
