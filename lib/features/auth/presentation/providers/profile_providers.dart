import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../application/state/profile_state.dart';
import '../../infraestructure/datasource/profile_datasource.dart';
import '../../infraestructure/repositories/profile_repository_impl.dart';
import '../controllers/profile_notifier.dart';

final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  final dio = ref.read(apiServiceProvider).dio;  // usa el dio con interceptor
  final datasource = ProfileDatasource(dio);
  return ProfileRepositoryImpl(datasource);
});

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return ProfileNotifier(repository);
});
