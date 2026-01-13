import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
//import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/providers/secure_storage_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../application/controllers/auth_notifier.dart';
import '../../application/state/auth_state.dart';
import '../../infraestructure/datasource/auth_datasource.dart';
import '../../infraestructure/datasource/auth_datasource_impl.dart';
import '../../infraestructure/repositories/auth_repository_impl.dart';

// 1. Provider del Datasource
final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  // Usamos watch para reconstruir si cambia el Dio (URL)
  final apiService = ref.watch(apiServiceProvider);
  return AuthDatasourceImpl(apiService.dio);
});

// 2. Provider del Repositorio
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authDatasourceProvider);
  final storage = ref.watch(secureStorageProvider);
  final apiService = ref.watch(apiServiceProvider);

  // Asegúrate de que el orden de los parámetros coincida con tu constructor en AuthRepositoryImpl
  // Según lo último que vimos era: (datasource, storage, apiService)
  return AuthRepositoryImpl(datasource, apiService, storage);
});

// 3. Provider del Notifier (Estado)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // ¡AQUÍ ESTABA EL PROBLEMA!
  // Antes usabas ref.read, por lo que el Notifier nunca se enteraba del cambio de backend.
  // Al usar ref.watch, si cambias el backend, este provider se reconstruye y crea un Notifier nuevo y fresco.
  final repository = ref.watch(authRepositoryProvider); 
  final storage = ref.watch(secureStorageProvider);
  
  return AuthNotifier(repository, storage);
});