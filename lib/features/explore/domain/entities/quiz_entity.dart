class QuizEntity {
  final String id;
  final String title;
  final String description;
  final String themeId;
  final String categoryName;
  final String coverImageUrl;
  final int playCount;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final String status;

  const QuizEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.themeId,
    required this.categoryName,
    required this.coverImageUrl,
    required this.playCount,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    required this.status,
  });
}