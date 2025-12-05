import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        accessToken: json['accessToken'],
        user: UserModel.fromJson(json['user']),
      );
}