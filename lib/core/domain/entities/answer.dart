class Answer {
  final String id;
  final String? text;
  final bool isCorrect;
  final String? mediaId;

  const Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.mediaId
  });
}