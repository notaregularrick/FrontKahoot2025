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
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      themeId: json['themeId']?.toString() ?? '',
      categoryName: json['category'] ?? 'General',
      coverImageUrl: json['coverImageId'] ?? 'https://via.placeholder.com/150',
      
      // Parseo robusto para playCount
      playCount: _parseInt(json['playCount']) ?? 0,
      
      authorId: authorJson?['id']?.toString() ?? '',
      authorName: authorJson?['name'] ?? 'Desconocido',
      
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      status: json['Status'] ?? 'draft',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}