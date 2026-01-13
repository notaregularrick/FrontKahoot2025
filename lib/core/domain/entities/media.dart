class Media {
  final String assetId;
  final String url;
  final String mimeType;
  final int size;
  final String format;
  final String category;

  const Media({
    required this.assetId,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.format,
    required this.category,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      assetId: json['assetId'] as String,
      url: json['url'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      format: json['format'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'url': url,
      'mimeType': mimeType,
      'size': size,
      'format': format,
      'category': category,
    };
  }
}
