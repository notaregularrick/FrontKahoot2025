class CurrentQuestion {
  final String questionId;
  final int questionIndex;
  final int timeLimitSeconds;
  final String questionText;
  final String? questionImageUrl;
  final String type;
  final List<QuestionAnswers> options;

  const CurrentQuestion({
    required this.questionId,
    required this.questionIndex,
    required this.questionText,
    this.questionImageUrl,
    required this.timeLimitSeconds,
    required this.type,
    required this.options,
  });

  String getAnswerTextByIndex(int index) {
    if (index < 0 || index >= options.length) {
      return '';
    } else {
      return options
          .firstWhere((option) => option.answerIndex == index)
          .answerText;
    }
  }
}

class QuestionAnswers {
  final int answerIndex;
  final String answerText;
  final String? answerImageUrl;

  const QuestionAnswers({
    required this.answerIndex,
    required this.answerText,
    this.answerImageUrl,
  });
}
