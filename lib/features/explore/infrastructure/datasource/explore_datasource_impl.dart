import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../models/pagination_model.dart';
import 'explore_datasource.dart';
import '../models/paginated_quizzes_model.dart';
import 'mock_data.dart';

class ExploreDatasourceImpl implements ExploreDatasource {
  
  final Dio dio;

  ExploreDatasourceImpl(this.dio);

  @override
  Future<PaginatedQuizzesModel> getQuizzes({
    String? searchQuery,
    List<String>? categories,
    int limit = 20,
    int page = 1,
    String? orderBy,
    String? order,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'page': page,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories;
      }

      if (orderBy != null) {
        queryParams['orderBy'] = orderBy;
      }

      if (order != null) {
        queryParams['order'] = order;
      }

      final response = await dio.get(
        '/explore',
        queryParameters: queryParams,
      );

      return PaginatedQuizzesModel.fromJson(response.data);
      
    } catch (e) {
      throw Exception('Error en ExploreDatasource: $e');
    }
  }

  @override
  Future<PaginatedQuizzesModel> getFeaturedQuizzes({int limit = 10}) async {
    try {
      
      final response = await dio.get(
        '/explore/featured',
        queryParameters: {'limit': limit},
      );
      
      final apiData = PaginatedQuizzesModel.fromJson(response.data);

      
      final combinedQuizzes = [
        mockQuiz1, 
        mockQuiz2, 
        ...apiData.quizzes 
      ];

      
      return PaginatedQuizzesModel(
        quizzes: combinedQuizzes,
        pagination: apiData.pagination, 
      );

    } catch (e) {
      print("Error en backend, mostrando solo mocks: $e");
      return PaginatedQuizzesModel(
        quizzes: [mockQuiz1, mockQuiz2],
        pagination: PaginationModel(page: 1, limit: 10, totalCount: 2, totalPages: 1),
      );
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get('/explore/categories');

      final List<dynamic> data = response.data as List<dynamic>;
      
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error en getCategories: $e');
    }
  }
}