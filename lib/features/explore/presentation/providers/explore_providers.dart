import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart'; // Asegúrate de que la ruta a tu api_service sea correcta
import '../../domain/repositories/explore_repository.dart';
import '../../infrastructure/datasource/explore_datasource.dart';
import '../../infrastructure/datasource/explore_datasource_impl.dart';
import '../../infrastructure/repositories/explore_repository_impl.dart';

// 1. Provider del Datasource
// Este se encarga de crear la instancia de ExploreDatasourceImpl pasándole el Dio configurado.
final exploreDatasourceProvider = Provider<ExploreDatasource>((ref) {
  // Leemos el servicio de API global para obtener la instancia de Dio
  final dio = ref.read(apiServiceProvider).dio;
  return ExploreDatasourceImpl(dio);
});

// 2. Provider del Repositorio
// Este crea el Repositorio inyectándole el Datasource que acabamos de crear arriba.
// La UI o los Notifiers consumirán ESTE provider.
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final datasource = ref.read(exploreDatasourceProvider);
  return ExploreRepositoryImpl(datasource);
});