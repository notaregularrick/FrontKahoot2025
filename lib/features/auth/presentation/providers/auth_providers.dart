import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/providers/secure_storage_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/network/dio_provider.dart' as core_dio;
import '../../domain/repositories/auth_repository.dart';
import '../../infraestructure/datasource/auth_datasource_impl.dart';
import '../../infraestructure/repositories/auth_repository_impl.dart';
import '../controllers/auth_notifier.dart';
import '../../application/state/auth_state.dart';

// Datasource Provider
final authDatasourceProvider = Provider((ref) {
  final dio = ref.watch(core_dio.dioProvider);
  return AuthDatasourceImpl(dio);
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.read(authDatasourceProvider);
  final apiService = ref.read(apiServiceProvider);
  final storage = ref.read(secureStorageProvider);

  return AuthRepositoryImpl(datasource,apiService,storage);
});

// Controller Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final storage = ref.read(secureStorageProvider);

  return AuthNotifier(repo, storage);
});
