import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../datasource/auth_datasource.dart';
import '../models/auth_response_model.dart';

class AuthDatasourceImpl implements AuthDatasource{

  final Dio _dio;

  AuthDatasourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        "email": email,
        "password": password,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        "name": name,
        "email": email,
        "password": password,
        "userType": "student"
      },
    );

    return UserModel.fromJson(response.data['user']);
  }

 /*  @override
 Future<UserModel?> checkAuthStatus(String token) async {
    final response = await _dio.get(
      '/auth/check-status',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      return UserModel(
        id: data['id'],
        email: data['email'],
        username: data['username'],
      );
    }

    return null;
  }*/
}