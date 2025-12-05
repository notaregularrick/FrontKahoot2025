class Media {
  final String id;
  final String mimeType;
  final int size;
  final String originalName;
  final DateTime createdAt;

  const Media({
    required this.id,
    required this.mimeType,
    required this.size,
    required this.originalName,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      originalName: json['originalName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mimeType': mimeType,
      'size': size,
      'originalName': originalName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

