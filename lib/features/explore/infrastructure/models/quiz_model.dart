import '../../domain/entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.title,
    required super.description,
    required super.themeId,
    required super.categoryName,
    required super.coverImageUrl,
    required super.playCount,
    required super.authorName,
    required super.authorId,
    required super.createdAt,
    required super.status,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>?;

    return QuizModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      themeId: json['themeId'] ?? '',
      categoryName: json['category'] ?? 'General',
      coverImageUrl: json['coverImageId'] ?? 'https://via.placeholder.com/150',
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      
      
      authorId: authorJson?['id'] ?? '',
      authorName: authorJson?['name'] ?? 'Desconocido',
      
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      status: json['Status'] ?? 'draft',
    );
  }
}