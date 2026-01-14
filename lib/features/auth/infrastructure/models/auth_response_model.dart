import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String accessToken; // Mapea a "token" en el JSON

  AuthResponseModel({
    required this.user,
    required this.accessToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      accessToken: json['token'] ?? '',
    );
  }
}