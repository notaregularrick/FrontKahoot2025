import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/domain/library_quiz.dart';
import 'package:frontkahoot2526/features/library/domain/library_repository.dart';

class FakeLibraryRepository implements ILibraryRepository {

  Map<String, dynamic> toQuery(LibraryFilterParams params) {
    Map<String, dynamic> query = {
      'page': params.page,
      'limit': params.limit,
      'status': params.status,
      'visibility': params.visibility,
      'orderBy': params.orderBy,
      'order': params.order,
    };
    if (params.search != null && params.search!.isNotEmpty) {
      query['search'] = params.search;
    }
    return query;
  }

  //H7.1 Quices creados y borradores
  @override
  Future<PaginatedResult<LibraryQuiz>> findMyCreations(
    LibraryFilterParams params,
  ) async {
    try {
      final Dio dio = Dio();
      Response response = await dio.get(
        'https://51939ed4-750b-431f-86da-d8cfde985ab8.mock.pstmn.io/kahoots/myCreations',
        queryParameters: toQuery(params),
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

  //H7.2 Quices favoritos
  @override
  Future<PaginatedResult<Quiz>> findFavorites(LibraryFilterParams params) {
    return Future.error('error');
  }

  //H7.3 Quices en progreso
  @override
  Future<PaginatedResult<Quiz>> findKahootsInProgress(
    LibraryFilterParams params,
  ) {
    return Future.error('error');
  }

  //H7.4 Quices completados
  @override
  Future<PaginatedResult<Quiz>> findCompletedKahoots(
    LibraryFilterParams params,
  ) {
    return Future.error('error');
  }
}

void main() async {
  // print('--- Iniciando prueba manual ---');

  // // 1. Instancia tu repositorio
  // final repository = FakeLibraryRepository();

  // // 2. Crea los params (asegúrate de importar la clase o copiarla aquí si da lío)
  // // Como tu LibraryFilterParams tiene valores por defecto, puedes instanciarlo vacío.
  // // Nota: Si te pide importar LibraryFilterParams, asegúrate de que el import sea relativo.
  // final params = LibraryFilterParams();

  // try {
  //   // 3. Ejecuta el método
  //   final result = await repository.findMyCreations(params);

  // } catch (e) {
  //   print('Error: $e');
  // }
  final repository = FakeLibraryRepository();
  final params = LibraryFilterParams();
  repository.findMyCreations(params);
}
