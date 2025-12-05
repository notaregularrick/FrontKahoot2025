import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/secure_storage_provider.dart';
//import '../services/secure_storage_service.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final storage = ref.read(secureStorageProvider);

  dio.interceptors.add(
    AuthInterceptor(ref, storage),
  );

  return dio;
});
