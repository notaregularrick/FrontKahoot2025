import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../models/paginated_quizzes_model.dart';
import 'explore_datasource.dart';

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

      if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;
      if (categories != null && categories.isNotEmpty) queryParams['categories'] = categories;
      if (orderBy != null) queryParams['orderBy'] = orderBy;
      if (order != null) queryParams['order'] = order;

      final response = await dio.get('/explore', queryParameters: queryParams);

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
      return PaginatedQuizzesModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error obteniendo destacados: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get('/explore/categories');

      final dynamic data = response.data;
      List<dynamic> listData;

      if (data is List) {
        listData = data;
      } else if (data is Map && data.containsKey('data') && data['data'] is List) {
        listData = data['data'];
      } else if (data is Map && data.containsKey('categories') && data['categories'] is List) {
        listData = data['categories'];
      } else {
        print("Formato de categorías desconocido: $data");
        return [];
      }
      
      return listData
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error en getCategories: $e');
    }
  }
}