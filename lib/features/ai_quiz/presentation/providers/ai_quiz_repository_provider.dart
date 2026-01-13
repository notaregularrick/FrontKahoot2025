import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/ai_quiz/domain/ai_quiz_repository.dart';
import 'package:frontkahoot2526/features/ai_quiz/infrastructure/ai_quiz_repository_impl.dart';
import 'package:frontkahoot2526/features/ai_quiz/presentation/providers/ai_api_key_provider.dart';

/// Provider que crea una instancia de Dio específica para Gemini API
/// Sin baseUrl ni interceptores de auth
final geminiDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
});

/// Provider para el repositorio de IA
/// Este provider depende de aiApiKeyProvider (FutureProvider)
/// Por lo tanto, debe ser usado con ref.watch() y manejar estados de loading/error
final aiQuizRepositoryProvider = Provider<IAIQuizRepository?>((ref) {
  final dio = ref.read(geminiDioProvider);
  final apiKeyAsync = ref.watch(aiApiKeyProvider);
  
  return apiKeyAsync.when(
    data: (apiKey) {
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }
      return AIQuizRepositoryImpl(
        dio: dio,
        apiKey: apiKey,
      );
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

