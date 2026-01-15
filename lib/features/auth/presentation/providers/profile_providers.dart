import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../application/state/profile_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../infrastructure/datasource/profile_datasource.dart';
import '../../infrastructure/datasource/profile_datasource_impl.dart';
import '../../infrastructure/repositories/profile_repository_impl.dart';
import '../../application/controllers/profile_notifier.dart';

// 1. Provider del Datasource
final profileDatasourceProvider = Provider<ProfileDatasource>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProfileDatasourceImpl(apiService.dio);
});

// 2. Provider del Repositorio
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final datasource = ref.watch(profileDatasourceProvider);
  return ProfileRepositoryImpl(datasource);
});

// 3. Provider del Notifier (Controlador de Estado)
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  
  return ProfileNotifier(repository);
});