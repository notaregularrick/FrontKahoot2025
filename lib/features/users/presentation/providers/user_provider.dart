import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../infrastructure/datasource/user_datasource.dart';
import '../../infrastructure/datasource/user_datasource_impl.dart';
import '../../infrastructure/repositories/user_repository_impl.dart';

// 1. Provider del Datasource
final userDatasourceProvider = Provider<UserDatasource>((ref) {
  final dio = ref.watch(apiServiceProvider).dio;
  return UserDatasourceImpl(dio);
});

// 2. Provider del Repositorio
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userDatasourceProvider);
  return UserRepositoryImpl(datasource);
});

// 3. Provider de la Lista de Usuarios (FutureProvider)
final usersListProvider = FutureProvider.autoDispose<List<UserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getAllUsers();
});