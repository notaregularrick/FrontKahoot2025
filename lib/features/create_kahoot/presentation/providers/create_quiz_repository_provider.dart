import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/network/dio_provider.dart';
import 'package:frontkahoot2526/features/create_kahoot/domain/create_quiz_repository.dart';
import 'package:frontkahoot2526/features/create_kahoot/infrastructure/create_quiz_repository_impl.dart';

final createQuizRepositoryProvider = Provider<ICreateQuizRepository>((ref) {
  final dio = ref.read(dioProvider);
  return CreateQuizRepositoryImpl(dio);
});

