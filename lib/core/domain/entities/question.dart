import 'answer.dart';

class Question {
  final String id;
  final String text;
  final String type; // 'quiz' | 'true_false'
  final int timeLimit;
  final int points;
  final String? mediaId;
  final List<Answer> answers;

  const Question({
    required this.id,
    required this.text,
    required this.type,
    required this.timeLimit,
    required this.points,
    this.mediaId,
    required this.answers,
  });
}