import 'question.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String? coverImageId;
  final String visibility; // 'public', 'private'
  final String status; // 'draft', 'published'
  final String category;
  final String themeId;
  final String authorId;
  final String authorName; // Para mostrar en la lista
  final List<Question> questions;
  final DateTime createdAt;
  final int playCount;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageId,
    required this.visibility,
    required this.status,
    required this.category,
    required this.themeId,
    required this.authorId,
    required this.authorName,
    required this.questions,
    required this.createdAt,
    required this.playCount,
  });
}