class LibraryQuiz {
  final String id;
  final String? title;
  final String? description;
  final String? coverImageId;
  final String visibility; // 'public', 'private'
  final String themeId;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int playCount;
  final String category;
  final String status; // 'draft', 'published'
  final String? gameId;
  final String? gameType;
  
  

  const LibraryQuiz({
    required this.id,
    this.title,
    this.description,
    this.coverImageId,
    required this.visibility,
    required this.status,
    required this.category,
    required this.themeId,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.playCount,
    this.gameId,
    this.gameType,
  });
}