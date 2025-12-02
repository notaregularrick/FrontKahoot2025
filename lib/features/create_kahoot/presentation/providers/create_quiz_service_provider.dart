import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/create_kahoot/application/create_quiz_service.dart';
import 'package:frontkahoot2526/features/create_kahoot/presentation/providers/create_quiz_repository_provider.dart';

final createQuizServiceProvider = Provider<CreateQuizService>((ref) {
  final repository = ref.read(createQuizRepositoryProvider);
  return CreateQuizService(repository);
});

