import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/secure_storage_provider.dart';
import '../../presentation/providers/auth_providers.dart';

class AuthInitializer {
  final Ref ref;

  AuthInitializer(this.ref);

  Future<void> init() async {
    final storage = ref.read(secureStorageProvider);

    final token = await storage.getToken();

    if (token != null) {
      // Inyectamos el token al AuthNotifier
      ref.read(authNotifierProvider.notifier).restoreSession(token);
    }
  }
}
