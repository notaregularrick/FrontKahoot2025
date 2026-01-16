class RegisterDeviceDto {
  final String token;
  final String deviceType;

  RegisterDeviceDto({
    required this.token,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'deviceType': deviceType,
    };
  }
}

