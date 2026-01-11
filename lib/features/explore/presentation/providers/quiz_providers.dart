import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../application/controllers/quiz_detail_notifier.dart';
import '../../application/state/quiz_state.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../infrastructure/datasource/quiz_datasource.dart';
import '../../infrastructure/datasource/quiz_datasource_impl.dart';
import '../../infrastructure/repositories/quiz_repository_impl.dart';

final quizDatasourceProvider = Provider<QuizDatasource>((ref) {
  final dio = ref.read(apiServiceProvider).dio;
  return QuizDatasourceImpl(dio);
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final datasource = ref.read(quizDatasourceProvider);
  return QuizRepositoryImpl(datasource);
});

final quizDetailProvider = StateNotifierProvider.family.autoDispose<QuizDetailNotifier, QuizDetailState, QuizDetailFamilyParams>(
  (ref, params) {
    // Leemos el REPOSITORIO
    final repository = ref.read(quizRepositoryProvider);
    return QuizDetailNotifier(repository, params.id, initialQuiz: params.quiz);
  },
);