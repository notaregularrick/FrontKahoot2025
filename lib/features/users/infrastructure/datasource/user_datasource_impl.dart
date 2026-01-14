import 'package:dio/dio.dart';
import '../../../auth/infrastructure/models/user_model.dart';
import 'user_datasource.dart';

class UserDatasourceImpl implements UserDatasource {
  final Dio dio;

  UserDatasourceImpl(this.dio);

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await dio.get('/user/');
      
      final List<dynamic> data = response.data;
      
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar la lista de usuarios: $e');
    }
  }
}