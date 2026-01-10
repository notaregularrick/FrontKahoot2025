import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/providers/backend_provider.dart';

import '../providers/secure_storage_provider.dart';
//import '../services/secure_storage_service.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final backendType = ref.watch(backendProvider);
  final currentUrl = backendType.url;

  final dio = Dio(
    BaseOptions(
      baseUrl: currentUrl,
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  final storage = ref.read(secureStorageProvider);

  dio.interceptors.add(AuthInterceptor(ref, storage));

  return dio;
});
