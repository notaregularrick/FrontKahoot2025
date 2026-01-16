import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../application/notifiers/backoffice_notifications_notifier.dart';
import '../../application/notifiers/backoffice_notifier.dart';
import '../../application/state/backoffice_notifications_state.dart';
import '../../domain/repositories/backoffice_repository.dart';
import '../../infrastructure/datasource/backoffice_datasource.dart';
import '../../infrastructure/datasource/backoffice_datasource_impl.dart';
import '../../infrastructure/repositories/backoffice_repository_impl.dart';
import '../../application/state/backoffice_state.dart';

// 1. Datasource
final backofficeDatasourceProvider = Provider<BackofficeDatasource>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BackofficeDatasourceImpl(apiService.dio);
});

// 2. Repository
final backofficeRepositoryProvider = Provider<BackofficeRepository>((ref) {
  final datasource = ref.watch(backofficeDatasourceProvider);
  return BackofficeRepositoryImpl(datasource);
});

// 3. Notifier
final backofficeNotifierProvider = StateNotifierProvider.autoDispose<BackofficeNotifier, BackofficeState>((ref) {
  final repository = ref.watch(backofficeRepositoryProvider);
  return BackofficeNotifier(repository);
});

final backofficeNotificationsProvider = StateNotifierProvider.autoDispose<BackofficeNotificationsNotifier, BackofficeNotificationsState>((ref) {
  final repository = ref.watch(backofficeRepositoryProvider);
  return BackofficeNotificationsNotifier(repository);
});