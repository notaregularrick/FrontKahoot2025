import 'user_model.dart';

class AuthResponseModel {
  final String token;
  final UserModel? user;

  AuthResponseModel({
    required this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json['token'] ?? json['accessToken'] ?? '',
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );
}