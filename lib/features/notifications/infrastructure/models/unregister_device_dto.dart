class UnregisterDeviceDto {
  final String token;

  UnregisterDeviceDto({
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

