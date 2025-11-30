import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';

class LibraryNotifierState{
  final List<QuizCardUiModel> quizList;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int limit;

  const LibraryNotifierState({
    required this.quizList,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });
}

