import '../../domain/entities/paginated_quizzes_entity.dart';
import 'pagination_model.dart';
import 'quiz_model.dart';

class PaginatedQuizzesModel extends PaginatedQuizzesEntity {
  const PaginatedQuizzesModel({
    required super.quizzes,
    required super.pagination,
  });

  factory PaginatedQuizzesModel.fromJson(Map<String, dynamic> json) {
    return PaginatedQuizzesModel(
      quizzes: (json['data'] as List<dynamic>?)
              ?.map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}