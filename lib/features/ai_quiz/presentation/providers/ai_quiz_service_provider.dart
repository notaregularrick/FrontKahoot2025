import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/ai_quiz/application/ai_quiz_service.dart';
import 'package:frontkahoot2526/features/ai_quiz/presentation/providers/ai_quiz_repository_provider.dart';

final aiQuizServiceProvider = Provider<AIQuizService?>((ref) {
  final repository = ref.read(aiQuizRepositoryProvider);
  if (repository == null) {
    return null;
  }
  return AIQuizService(repository);
});

