import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/create_kahoot/domain/create_quiz_repository.dart';
import 'package:frontkahoot2526/features/create_kahoot/infrastructure/fake_create_quiz_repository_impl.dart';

final createQuizRepositoryProvider = Provider<ICreateQuizRepository>((ref) {
  return FakeCreateQuizRepository();
});

