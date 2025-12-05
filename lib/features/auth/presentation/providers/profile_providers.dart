import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../application/state/profile_state.dart';
import '../../infraestructure/datasource/profile_datasource.dart';
import '../../infraestructure/repositories/profile_repository_impl.dart';
import '../controllers/profile_notifier.dart';

final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  // 1. Obtenemos el servicio completo (ApiService)
  final apiService = ref.read(apiServiceProvider);
  
  // 2. Obtenemos Dio del servicio para el Datasource
  final dio = apiService.dio; 
  
  // 3. Creamos el Datasource
  final datasource = ProfileDatasource(dio);

  // 4. CORRECCIÓN: Pasamos AMBOS al repositorio
  return ProfileRepositoryImpl(datasource, apiService);
});

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return ProfileNotifier(repository);
});