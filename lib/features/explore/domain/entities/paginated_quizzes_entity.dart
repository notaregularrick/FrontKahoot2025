import 'quiz_entity.dart';
import 'pagination_entity.dart';

class PaginatedQuizzesEntity {
  final List<QuizEntity> quizzes;
  final PaginationEntity pagination;

  const PaginatedQuizzesEntity({
    required this.quizzes,
    required this.pagination,
  });
}