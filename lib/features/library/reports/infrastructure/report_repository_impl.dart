import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
import 'package:frontkahoot2526/features/library/reports/domain/personal_question_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/personal_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/player_ranking.dart';
import 'package:frontkahoot2526/features/library/reports/domain/question_analysis.dart';
import 'package:frontkahoot2526/features/library/reports/domain/report.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_filter_params.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_repository.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';

class ReportRepositoryImpl implements IReportsRepository {
  final Dio _dio;
  ReportRepositoryImpl(this._dio);
  Map<String, dynamic> toQuery(ReportsFilterParams params) {
    Map<String, dynamic> query = {'page': params.page, 'limit': params.limit};
    return query;
  }

  processGameType(String gameTypeStr) {
    switch (gameTypeStr) {
      case 'Multiplayer_host' ||
          'multiplayerHost' ||
          'multiplayer_host' ||
          'MultiplayerHost':
        return GameType.multiplayerHost;
      case 'Multiplayer_player' ||
          'multiplayerPlayer' ||
          'multiplayer_player' ||
          'MultiplayerPlayer':
        return GameType.multiplayerPlayer;
      case 'Singleplayer' || 'singleplayer':
        return GameType.singleplayer;
      default:
        throw AppException(
          message: "Tipo de juego desconocido",
          statusCode: 400,
          error: 'El tipo de juego $gameTypeStr no es válido',
        );
    }
  }

  @override
  Future<PaginatedResult<Results>> findMyResults(
    ReportsFilterParams params,
  ) async {
    try {
      Response response = await _dio.get(
        '/reports/kahoots/my-results',
        queryParameters: toQuery(params),
      );
      debugPrint('Empezando');
      final Map<String, dynamic> responseBody = response.data;
      final List<dynamic> data = responseBody['results'];
      debugPrint('Sigo');
      List<Results> resultsList = [];
      for (var item in data) {
        String kahootId = item['kahootId'] as String;
        String gameId = item['gameId'] as String;
        GameType gameType = processGameType(item['gameType'] as String);
        String title = item['title'] as String;
        DateTime completionDate = DateTime.parse(
          item['completionDate'] as String,
        );
        int finalScore = (item['finalScore'] as num?)?.toInt() ?? 0;
        int? rankingPosition = (item['rankingPosition'] as num?)?.toInt();
        resultsList.add(
          Results(
            kahootId: kahootId,
            gameId: gameId,
            gameType: gameType,
            title: title,
            completionDate: completionDate,
            finalScore: finalScore,
            rankingPosition: rankingPosition,
          ),
        );
      }
      final Map<String, dynamic> paginationData =
          (responseBody['meta'] ?? responseBody['pagination']) ?? {};
      final PaginatedResult<Results> paginatedResult = PaginatedResult(
        items: resultsList,
        totalCount: paginationData['totalItems'] as int,
        totalPages: paginationData['totalPages'] as int,
        currentPage: paginationData['currentPage'] as int,
        limit: paginationData['limit'] as int,
      );
      debugPrint('BIEEEEN');
      return paginatedResult;
    } on DioException catch (e) {
      debugPrint('AQI' + e.toString());
      if (e.response != null) {
        final data = e.response!.data;
        throw AppException(
          message: data['message'] as String,
          statusCode: data['statusCode'] as int?,
          error: data['error'] as String?,
        );
      } else {
        debugPrint('AQI' + e.toString());
        throw AppException(message: 'Error desconocido', statusCode: 500);
      }
    } catch (e) {
      debugPrint('AQI' + e.toString());
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  Future<PersonalResult> getPersonalResult(String id, GameType gameType) async {
    //el id puede ser de session o attempt dependiendo del gameType
    try {
      String path;
      switch (gameType) {
        case GameType.multiplayerPlayer:
          {
            path = "/reports/multiplayer/$id";
          }
        case GameType.singleplayer:
          {
            path = "/reports/singleplayer/$id";
          }
        default:
          {
            throw AppException(
              message: "Tipo de juego no soportado para resultados personales",
              statusCode: 400,
              error: 'El tipo de juego $gameType no es válido',
            );
          }
      }
      Response response = await _dio.get(path);
      final Map<String, dynamic> responseBody = response.data;
      String kahootId = responseBody['kahootId'] as String;
      String title = responseBody['title'] as String;
      String userId = responseBody['userId'] as String;
      int finalScore = (responseBody['finalScore'] as num?)?.toInt() ?? 0;
      int correctAnswers =
          (responseBody['correctAnswers'] as num?)?.toInt() ?? 0;
      int totalQuestions =
          (responseBody['totalQuestions'] as num?)?.toInt() ?? 0;
      num averageTimeMs = responseBody['averageTimeMs'] as num? ?? 0;
      int? rankingPosition = responseBody['rankingPosition'] != null
          ? (responseBody['rankingPosition'] as num).toInt()
          : null;

      List<PersonalQuestionResult> questionResults = [];
      List<dynamic> questionsData = responseBody['questionResults'];
      for (var item in questionsData) {
        int questionIndex = (item['questionIndex'] as num?)?.toInt() ?? 0;
        String questionText = item['questionText'] as String;
        bool isCorrect = item['isCorrect'] as bool? ?? false;
        List<String> answerText =
            (item['answerText'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        List<String> answerMediaId =
            (item['answerMediaId'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        num timeTakenMs = item['timeTakenMs'] as num? ?? 0;
        questionResults.add(
          PersonalQuestionResult(
            questionIndex: questionIndex,
            questionText: questionText,
            isCorrect: isCorrect,
            answerText: answerText,
            answerMediaId: answerMediaId,
            timeTakenMs: timeTakenMs,
          ),
        );
      }

      return PersonalResult(
        kahootId: kahootId,
        title: title,
        userId: userId,
        finalScore: finalScore,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        averageTimeMs: averageTimeMs,
        rankingPosition: rankingPosition,
        questionResults: questionResults,
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

  @override
  Future<Report> getGeneralReport(String id) async {
    try {
      Response response = await _dio.get('/reports/sessions/$id');
      final Map<String, dynamic> responseBody = response.data;
      String sessionId = responseBody['sessionId'] as String;
      String title = responseBody['title'] as String;
      DateTime executionDate = DateTime.parse(
        responseBody['executionDate'] as String,
      );

      List<PlayerRanking> playerRanking = [];
      List<dynamic> rankingData = responseBody['playerRanking'];
      for (var item in rankingData) {
        int position = (item['position'] as num?)?.toInt() ?? 0;
        String username = item['username'] as String;
        int score = (item['score'] as num?)?.toInt() ?? 0;
        int correctAnswers = (item['correctAnswers'] as num?)?.toInt() ?? 0;
        playerRanking.add(
          PlayerRanking(
            position: position,
            username: username,
            score: score,
            correctAnswers: correctAnswers,
          ),
        );
      }

      List<Questionanalysis> questionAnalysis = [];
      List<dynamic> questionsData = responseBody['questionAnalysis'];
      for (var item in questionsData) {
        int questionIndex = (item['questionIndex'] as num?)?.toInt() ?? 0;
        String questionText = item['questionText'] as String;
        num correctPercentage = item['correctPercentage'] as num? ?? 0;
        questionAnalysis.add(
          Questionanalysis(
            questionIndex: questionIndex,
            questionText: questionText,
            correctPercentage: correctPercentage,
          ),
        );
      }

      return Report(
        sessionId: sessionId,
        title: title,
        executionDate: executionDate,
        playerRanking: playerRanking,
        questionAnalysis: questionAnalysis,
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
