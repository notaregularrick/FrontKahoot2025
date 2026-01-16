class HostSessionInfo {
  String sessionPin;
  String qrToken;
  String quizTitle;
  String coverImageUrl;

  HostSessionInfo({
    required this.sessionPin,
    required this.qrToken,
    required this.quizTitle,
    required this.coverImageUrl,
  });

  factory HostSessionInfo.fromJson(Map<String, dynamic> json) {
    return HostSessionInfo(
      sessionPin: json['sessionPin'] as String? ?? '',
      qrToken: json['qrToken'] as String? ?? '',
      quizTitle: json['quizTitle'] as String? ?? 'Quiz sin título',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
    );
  }

  void logDebugInfo() {
    print('\n===== ℹ️ HOST SESSION INFO =====');
    print('📌 PIN de Sesión: $sessionPin');
    print('📝 Título: "$quizTitle"');
    print('🎟️ QR Token: $qrToken');
    print(
      '🖼️ Cover URL: ${coverImageUrl.isEmpty ? "Sin imagen" : coverImageUrl}',
    );
    print('================================\n');
  }
}

void main(List<String> args) {
  final mockData = {
    "sessionPin": "1507780",
    "qrToken": "2141405e-e040-4ab2-80bc-5b0b1a8b9c08",
    "quizTitle": "Patrones de Diseño GoF (Gang of FouAAAAr)",
    "coverImageUrl":
        "https://res.cloudinary.com/dcmbpjmqs/image/upload/v1/quizzy_assets/themes/tema-1-f410f1?_a=BAMAMiZW0",
    "theme": {
      "id": "5f0e8c89-f434-4dff-baaf-83a4aa4feb26",
      "url":
          "https://res.cloudinary.com/dcmbpjmqs/image/upload/v1/quizzy_assets/themes/tema-3-5f0e8c?_a=BAMAMiZW0",
      "name": "Tema 3",
    },
  };
  final sessionInfo = HostSessionInfo.fromJson(mockData);
  sessionInfo.logDebugInfo();
}
