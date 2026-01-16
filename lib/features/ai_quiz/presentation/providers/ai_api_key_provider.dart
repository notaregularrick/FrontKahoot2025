import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/providers/secure_storage_provider.dart';

/// Provider para la API key de Gemini
/// Lee la API key desde SecureStorage
final aiApiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.read(secureStorageProvider);
  return await storage.getGeminiApiKey();
});


