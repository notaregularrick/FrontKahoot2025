import 'package:frontkahoot2526/features/library/reports/domain/personal_question_result.dart';

class PersonalResult {
  final String kahootId;
  final String title;
  final String userId;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final num averageTimeMs;
  final int? rankingPosition;
  final List<PersonalQuestionResult> questionResults;

  const PersonalResult({
    required this.kahootId,
    required this.title,
    required this.userId,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.averageTimeMs,
    this.rankingPosition,
    required this.questionResults,
  });
}