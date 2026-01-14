import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/domain/library_quiz.dart';
import 'package:frontkahoot2526/features/library/domain/library_repository.dart';

class LibraryRepositoryImpl implements ILibraryRepository {
  final Dio _dio;
  LibraryRepositoryImpl(this._dio);
  Map<String, dynamic> toQuery(LibraryFilterParams params) {
    Map<String, dynamic> query = {
      'page': params.page,
      'limit': params.limit,
      'status': params.status,
      'visibility': params.visibility,
      'orderBy': params.orderBy,
      'order': params.order,
    };
    if (params.q != null && params.q!.isNotEmpty) {
      query['q'] = params.q;
    }
    return query;
  }

  //H7.1 Quices creados y borradores
  @override
  Future<PaginatedResult<LibraryQuiz>> findMyCreations(
    LibraryFilterParams params,
  ) async {
    try {
      Response response = await _dio.get(
        '/library/my-creations',
        queryParameters: toQuery(params),
        data: {"userId": "8e5c1f34-cd53-4180-8e6d-da2bd5399f62"}//QUITAR
      );
      final Map<String, dynamic> responseBody = response.data;
      final List<dynamic> data = responseBody['data'];
      List<LibraryQuiz> quizzes = [];
      for (var quiz in data) {
        String id = quiz['id'] as String;
        String? title = quiz['title'] as String?;
        String? description = quiz['description'] as String?;
        String? coverImageId = quiz['coverImageId'] as String?;
        String visibility = quiz['visibility'] as String;
        String themeId = quiz['themeId'] as String;
        Map<String, dynamic> author = quiz['author'] as Map<String, dynamic>;
        String authorId = author['id'] as String;
        String authorName = author['name'] as String;
        DateTime createdAt = DateTime.parse(quiz['createdAt'] as String);
        int playCount = (quiz['playCount'] as num?)?.toInt() ?? 0;
        String category = quiz['category'] as String;
        String status = quiz['status'] as String;

        LibraryQuiz newQuiz = LibraryQuiz(
          id: id,
          title: title,
          description: description,
          coverImageId: coverImageId,
          visibility: visibility,
          status: status,
          category: category,
          themeId: themeId,
          authorId: authorId,
          authorName: authorName,
          createdAt: createdAt,
          playCount: playCount,
        );
        quizzes.add(newQuiz);
      }

      final Map<String, dynamic> paginationData = responseBody['pagination'];
      final PaginatedResult<LibraryQuiz> paginatedResult = PaginatedResult(
        items: quizzes,
        totalCount: paginationData['totalCount'] as int,
        totalPages: paginationData['totalPages'] as int,
        currentPage: paginationData['page'] as int,
        limit: paginationData['limit'] as int,
      );
      return paginatedResult;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        throw AppException(
          message: data['message'] as String,
          statusCode: data['statusCode'] as int?,
          error: data['error'] as String?,
        );
      } else {
        throw AppException(message: 'Error desconocido', statusCode: 500);
      }
    } catch (e) {
      print(e);
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
      
    }
  }

  //H7.2 Quices favoritos
  @override
  Future<PaginatedResult<LibraryQuiz>> findFavorites(
    LibraryFilterParams params,
  ) async {
    try {
      Response response = await _dio.get(
        '/library/favorites',
        queryParameters: toQuery(params),
        data: {"userId": "123e4567-e89b-42d3-a456-426614174123"}//QUITAR
      );
      final Map<String, dynamic> responseBody = response.data;
      final List<dynamic> data = responseBody['data'];
      List<LibraryQuiz> quizzes = [];
      for (var quiz in data) {
        String id = quiz['id'] as String;
        String? title = quiz['title'] as String?;
        String? description = quiz['description'] as String?;
        String? coverImageId = quiz['coverImageId'] as String?;
        String visibility = quiz['visibility'] as String;
        String themeId = quiz['themeId'] as String;
        Map<String, dynamic> author = quiz['author'] as Map<String, dynamic>;
        String authorId = author['id'] as String;
        String authorName = author['name'] as String;
        DateTime createdAt = DateTime.parse(quiz['createdAt'] as String);
        int playCount = (quiz['playCount'] as num?)?.toInt() ?? 0;
        String category = quiz['category'] as String;
        String status = quiz['status'] as String;

        LibraryQuiz newQuiz = LibraryQuiz(
          id: id,
          title: title,
          description: description,
          coverImageId: coverImageId,
          visibility: visibility,
          status: status,
          category: category,
          themeId: themeId,
          authorId: authorId,
          authorName: authorName,
          createdAt: createdAt,
          playCount: playCount,
        );
        quizzes.add(newQuiz);
      }

      final Map<String, dynamic> paginationData = responseBody['pagination'];
      final PaginatedResult<LibraryQuiz> paginatedResult = PaginatedResult(
        items: quizzes,
        totalCount: paginationData['totalCount'] as int,
        totalPages: paginationData['totalPages'] as int,
        currentPage: paginationData['page'] as int,
        limit: paginationData['limit'] as int,
      );
      return paginatedResult;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        throw AppException(
          message: data['message'] as String,
          statusCode: data['statusCode'] as int?,
          error: data['error'] as String?,
        );
      } else {
        throw AppException(message: 'Error desconocido', statusCode: 500);
      }
    } catch (e) {
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  //H7.3 Quices en progreso
  @override
  Future<PaginatedResult<LibraryQuiz>> findQuizzesInProgress(
    LibraryFilterParams params,
  ) async {
    try {
      Response response = await _dio.get(
        '/library/in-progress',
        queryParameters: toQuery(params),
        data: {"userId": "123e4567-e89b-42d3-a456-426614174123"}//QUITAR
      );
      final Map<String, dynamic> responseBody = response.data;
      final List<dynamic> data = responseBody['data'];
      List<LibraryQuiz> quizzes = [];
      for (var quiz in data) {
        // ignore: avoid_print
        print('[library][in-progress][item] $quiz');
        String id = quiz['id'] as String;
        String? title = quiz['title'] as String?;
        String? description = quiz['description'] as String?;
        String? coverImageId = quiz['coverImageId'] as String?;
        String visibility = quiz['visibility'] as String;
        String themeId = quiz['themeId'] as String;
        Map<String, dynamic> author = quiz['author'] as Map<String, dynamic>;
        String authorId = author['id'] as String;
        String authorName = author['name'] as String;
        DateTime createdAt = DateTime.parse(quiz['createdAt'] as String);
        int playCount = (quiz['playCount'] as num?)?.toInt() ?? 0;
        String category = quiz['category'] as String;
        String status = quiz['status'] as String;
        // Robust extraction for in-progress identifiers and type
        String? gameId = (quiz['gameId'] ?? quiz['attemptId'] ?? quiz['attemptID'] ?? quiz['sessionId'] ?? quiz['sessionID']) as String?;
        String? gameType = (quiz['gameType'] ?? quiz['type'])?.toString();
        if (gameType == null) {
          if (quiz['attemptId'] != null || quiz['attemptID'] != null) gameType = 'singleplayer';
          else if (quiz['sessionId'] != null || quiz['sessionID'] != null) gameType = 'multiplayer';
          else gameType = 'singleplayer'; // default fallback
        }

        LibraryQuiz newQuiz = LibraryQuiz(
          id: id,
          title: title,
          description: description,
          coverImageId: coverImageId,
          visibility: visibility,
          status: status,
          category: category,
          themeId: themeId,
          authorId: authorId,
          authorName: authorName,
          createdAt: createdAt,
          playCount: playCount,
          gameId: gameId,
          gameType: gameType,
        );
        quizzes.add(newQuiz);
      }

      final Map<String, dynamic> paginationData = responseBody['pagination'];
      final PaginatedResult<LibraryQuiz> paginatedResult = PaginatedResult(
        items: quizzes,
        totalCount: paginationData['totalCount'] as int,
        totalPages: paginationData['totalPages'] as int,
        currentPage: paginationData['page'] as int,
        limit: paginationData['limit'] as int,
      );
      return paginatedResult;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        throw AppException(
          message: data['message'] as String,
          statusCode: data['statusCode'] as int?,
          error: data['error'] as String?,
        );
      } else {
        throw AppException(message: 'Error desconocido', statusCode: 500);
      }
    } catch (e) {
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  //H7.4 Quices completados
  @override
  Future<PaginatedResult<LibraryQuiz>> findCompletedQuizzes(
    LibraryFilterParams params,
  ) async {
    try {
      Response response = await _dio.get(
        '/library/completed',
        queryParameters: toQuery(params),
        data: {"userId": "123e4567-e89b-42d3-a456-426614174123"}//QUITAR
      );
      final Map<String, dynamic> responseBody = response.data;
      final List<dynamic> data = responseBody['data'];
      List<LibraryQuiz> quizzes = [];
      for (var quiz in data) {
        String id = quiz['id'] as String;
        String? title = quiz['title'] as String?;
        String? description = quiz['description'] as String?;
        String? coverImageId = quiz['coverImageId'] as String?;
        String visibility = quiz['visibility'] as String;
        String themeId = quiz['themeId'] as String;
        Map<String, dynamic> author = quiz['author'] as Map<String, dynamic>;
        String authorId = author['id'] as String;
        String authorName = author['name'] as String;
        DateTime createdAt = DateTime.parse(quiz['createdAt'] as String);
        int playCount = (quiz['playCount'] as num?)?.toInt() ?? 0;
        String category = quiz['category'] as String;
        String status = quiz['status'] as String;
        // Robust extraction for completed identifiers and type
        String? gameId = (quiz['gameId'] ?? quiz['attemptId'] ?? quiz['attemptID'] ?? quiz['sessionId'] ?? quiz['sessionID']) as String?;
        String? gameType = (quiz['gameType'] ?? quiz['type'])?.toString();
        if (gameType == null) {
          if (quiz['attemptId'] != null || quiz['attemptID'] != null) gameType = 'singleplayer';
          else if (quiz['sessionId'] != null || quiz['sessionID'] != null) gameType = 'multiplayer';
          else gameType = 'singleplayer'; // default fallback
        }

        LibraryQuiz newQuiz = LibraryQuiz(
          id: id,
          title: title,
          description: description,
          coverImageId: coverImageId,
          visibility: visibility,
          status: status,
          category: category,
          themeId: themeId,
          authorId: authorId,
          authorName: authorName,
          createdAt: createdAt,
          playCount: playCount,
          gameId: gameId,
          gameType: gameType,
        );
        quizzes.add(newQuiz);
      }

      final Map<String, dynamic> paginationData = responseBody['pagination'];
      final PaginatedResult<LibraryQuiz> paginatedResult = PaginatedResult(
        items: quizzes,
        totalCount: paginationData['totalCount'] as int,
        totalPages: paginationData['totalPages'] as int,
        currentPage: paginationData['page'] as int,
        limit: paginationData['limit'] as int,
      );
      return paginatedResult;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        throw AppException(
          message: data['message'] as String,
          statusCode: data['statusCode'] as int?,
          error: data['error'] as String?,
        );
      } else {
        throw AppException(message: 'Error desconocido', statusCode: 500);
      }
    } catch (e) {
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> addQuizToFavorite(String quizId) async {
    try {
      final Dio dio = Dio();
      await dio.post(
        '/library/favorites/$quizId',
        data: {"userId": "123e4567-e89b-42d3-a456-426614174123"}//QUITAR
      );
    } on DioException catch (e) {
      print(e);
      if (e.response != null) {
        final data = e.response!.data;
        throw AppException(
          message: data['message'] as String,
          statusCode: data['statusCode'] as int?,
          error: data['error'] as String?,
        );
      } else {
        throw AppException(message: 'Error desconocido', statusCode: 500);
      }
    } catch (e) {
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> removeQuizFromFavorite(String quizId) async {
    try {
      final Dio dio = Dio();
      await dio.delete(
        '/library/favorites/$quizId',
        data: {"userId": "123e4567-e89b-42d3-a456-426614174123"}//QUITAR
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        throw AppException(
          message: data['message'] as String,
          statusCode: data['statusCode'] as int?,
          error: data['error'] as String?,
        );
      } else {
        throw AppException(message: 'Error desconocido', statusCode: 500);
      }
    } catch (e) {
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }
}