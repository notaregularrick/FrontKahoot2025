import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart'; // Asegúrate de que la ruta a tu api_service sea correcta
import '../../application/controllers/explore_notifier.dart';
import '../../application/state/explore_state.dart';
import '../../domain/repositories/explore_repository.dart';
import '../../infrastructure/datasource/explore_datasource.dart';
import '../../infrastructure/datasource/explore_datasource_impl.dart';
import '../../infrastructure/repositories/explore_repository_impl.dart';

// 1. Provider del Datasource
final exploreDatasourceProvider = Provider<ExploreDatasource>((ref) {
  final dio = ref.watch(apiServiceProvider).dio;
  return ExploreDatasourceImpl(dio);
});

// 2. Provider del Repositorio
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final datasource = ref.watch(exploreDatasourceProvider);
  return ExploreRepositoryImpl(datasource);
});

// 3. Provider del Notifier (Estado)
final exploreNotifierProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((ref) {
  final repository = ref.watch(exploreRepositoryProvider);
  return ExploreNotifier(repository);
});