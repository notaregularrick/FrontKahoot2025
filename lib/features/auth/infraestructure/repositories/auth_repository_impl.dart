//import 'package:dio/dio.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasource/auth_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository{

  final AuthDatasource datasource;
  final ApiService apiService;
  final SecureStorageService storage;

  AuthRepositoryImpl(this.datasource, this.apiService, this.storage);

 
  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    
    final userModel = await datasource.register(
      name: name,
      email: email,
      password: password,
    );

    
    return userModel.toEntity();
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    
    final response = await datasource.login(
      email:email,
      password:password,
    );

    return response;
  }

  @override
  Future<void> logout() async {
    await apiService.post('/auth/logout');
    // El backend da 204, no hay body
  }

}