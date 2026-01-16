import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/services/api_service.dart';
import 'package:frontkahoot2526/core/services/fcm_service.dart';
import 'package:frontkahoot2526/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/datasource/notifications_datasource.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/datasource/notifications_datasource_impl.dart';
import 'package:frontkahoot2526/features/notifications/infrastructure/repositories/notifications_repository_impl.dart';

// Provider del servicio FCM
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService.instance;
});

// Provider del Datasource
final notificationsDatasourceProvider = Provider<NotificationsDatasource>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return NotificationsDatasourceImpl(apiService.dio);
});

// Provider del Repositorio
final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final datasource = ref.watch(notificationsDatasourceProvider);
  return NotificationsRepositoryImpl(datasource);
});
