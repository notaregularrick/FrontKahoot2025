import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasource/auth_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;
  final ApiService apiService;
  final SecureStorageService storage;

  AuthRepositoryImpl(this.datasource, this.apiService, this.storage);

  @override
  Future<UserEntity?> register({
    required String name,
    required String email,
    required String password,
    required String username, 
    required String userType,
  }) async {
    // Llamamos al datasource
    final userModel = await datasource.register(
      name: name,
      email: email,
      password: password,
      username: username,
      userType: userType,
    );
    
    return userModel.toEntity();
  }

  @override
  Future<AuthResponseModel> login({required String username, required String password}) async {
    // Pasamos username al datasource
    final response = await datasource.login(username: username, password: password);
    await storage.saveToken(response.accessToken);
    return response;
  }

  @override
  Future<AuthResponseModel> checkAuthStatus() async {
    // 1. Leemos el token guardado
    final token = await storage.getToken();

    if (token == null) {
      throw Exception('No hay token guardado');
    }

    try {
      // 2. Verificamos con el backend y obtenemos token renovado
      final response = await datasource.checkAuthStatus(token);
      
      // 3. Guardamos el NUEVO token
      await storage.saveToken(response.accessToken);
      
      return response;
    } catch (e) {
      // Si falla (token expirado), limpiamos todo
      await logout();
      throw Exception('Sesión expirada');
    }
  }

  @override
  Future<void> logout() async {
    await storage.deleteToken();
  }
}
