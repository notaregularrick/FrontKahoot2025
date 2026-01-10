class MediaTheme {
  final String assetId;
  final String url;
  final String name;
  final String category;
  final String format;
  final int size;
  final String mimeType;

  const MediaTheme({
    required this.assetId,
    required this.url,
    required this.name,
    required this.category,
    required this.format,
    required this.size,
    required this.mimeType,
  });

  factory MediaTheme.fromJson(Map<String, dynamic> json) {
    return MediaTheme(
      assetId: json['assetId'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      format: json['format'] as String,
      size: json['size'] as int,
      mimeType: json['mimeType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'url': url,
      'name': name,
      'category': category,
      'format': format,
      'size': size,
      'mimeType': mimeType,
    };
  }
}

