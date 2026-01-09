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

class FakeReportRepositoryImpl implements IReportsRepository {
  Map<String, dynamic> toQuery(ReportsFilterParams params) {
    Map<String, dynamic> query = {
      'page': params.page,
      'limit': params.limit,
      'order': params.order,
    };
    return query;
  }

  processGameType(String gameTypeStr) {
    switch (gameTypeStr) {
      case 'Multiplayer' || 'multiplayer':
        return GameType.multiplayer;
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

  Map<String, dynamic> get mockFindMyResults => {
    "results": [
      {
        "kahootId": "123e4567-e89b-12d3-a456-426614174000",
        "gameId": "a1b2c3d4-e89b-12d3-a456-426614174001",
        "gameType": "Multiplayer",
        "title": "Capitales de Europa - Desafío Final",
        "completionDate": "2025-10-25T14:30:00.000Z",
        "finalScore": 12500,
        "rankingPosition": 1,
      },
      {
        "kahootId": "223e4567-e89b-12d3-a456-426614174002",
        "gameId": "b1b2c3d4-e89b-12d3-a456-426614174002",
        "gameType": "Singleplayer",
        "title": "Matemáticas Básicas: Álgebra",
        "completionDate": "2025-10-24T09:15:00.000Z",
        "finalScore": 8400,
        "rankingPosition": null,
      },
      {
        "kahootId": "323e4567-e89b-12d3-a456-426614174003",
        "gameId": "c1b2c3d4-e89b-12d3-a456-426614174003",
        "gameType": "Multiplayer",
        "title": "Cultura General 2025",
        "completionDate": "2025-10-23T18:45:00.000Z",
        "finalScore": 6200,
        "rankingPosition": 5,
      },
      {
        "kahootId": "423e4567-e89b-12d3-a456-426614174004",
        "gameId": "d1b2c3d4-e89b-12d3-a456-426614174004",
        "gameType": "Singleplayer",
        "title": "Repaso de Historia: La Revolución Industrial",
        "completionDate": "2025-10-20T10:00:00.000Z",
        "finalScore": 3000,
        "rankingPosition": null,
      },
      {
        "kahootId": "523e4567-e89b-12d3-a456-426614174005",
        "gameId": "e1b2c3d4-e89b-12d3-a456-426614174005",
        "gameType": "Multiplayer",
        "title": "Quiz de Programación en Dart",
        "completionDate": "2025-10-15T20:20:00.000Z",
        "finalScore": 9800,
        "rankingPosition": 2,
      },
    ],
    "meta": {"totalItems": 7, "currentPage": 1, "totalPages": 2, "limit": 10},
  };

  Map<String, dynamic> get mockFindMyResults2 => {
    "results": [
      {
        "kahootId": "123e4567-e89b-12d3-a456-426614174000",
        "gameId": "a1b2c3d4-e89b-12d3-a456-426614174001",
        "gameType": "Multiplayer",
        "title": "Capitales de Europa - Desafío Final",
        "completionDate": "2025-10-25T14:30:00.000Z",
        "finalScore": 12500,
        "rankingPosition": 1,
      },
      {
        "kahootId": "223e4567-e89b-12d3-a456-426614174002",
        "gameId": "b1b2c3d4-e89b-12d3-a456-426614174002",
        "gameType": "Singleplayer",
        "title": "Matemáticas Básicas: Álgebra",
        "completionDate": "2025-10-24T09:15:00.000Z",
        "finalScore": 8400,
        "rankingPosition": null,
      },
    ],
    "meta": {"totalItems": 7, "currentPage": 2, "totalPages": 2, "limit": 10},
  };

  Map<String, dynamic> get mockPersonalMultiplayerResults => {
    "kahootId": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Capitales de Europa - Desafío Final",
    "userId": "98765432-e89b-12d3-a456-426614174099",
    "finalScore": 12500,
    "correctAnswers": 4,
    "totalQuestions": 4,
    "averageTimeMs": 5425,
    "questionResults": [
      {
        "questionIndex": 0,
        "questionText": "¿Cuál es la capital de Francia?",
        "isCorrect": true,
        "answerText": ["París"],
        "answerMediaID": [],
        "timeTakenMs": 4500,
      },
      {
        "questionIndex": 1,
        "questionText": "¿Qué imagen corresponde a una célula vegetal?",
        "isCorrect": true,
        "answerText": [],
        "answerMediaID": [
          "https://cdn.example.com/biology/plant-cell.png",
          "https://cdn.example.com/biology/plant-cell.png",
        ],
        "timeTakenMs": 6100,
      },
      {
        "questionIndex": 2,
        "questionText": "¿En qué año cayó el Muro de Berlín?",
        "isCorrect": true,
        "answerText": ["1989"],
        "answerMediaID": [],
        "timeTakenMs": 8200,
      },
      {
        "questionIndex": 3,
        "questionText": "Selecciona los colores primarios luz (Modelo RGB)",
        "isCorrect": true,
        "answerText": ["Rojo", "Verde", "Azul"],
        "answerMediaID": [],
        "timeTakenMs": 2900,
      },
    ],
  };

  Map<String, dynamic> get mockPersonalSingleplayerResults => {
    "kahootId": "223e4567-e89b-12d3-a456-426614174002",
    "title": "Matemáticas Básicas: Álgebra",
    "userId": "98765432-e89b-12d3-a456-426614174099",
    "finalScore": 8400,
    "correctAnswers": 4,
    "totalQuestions": 5,
    "averageTimeMs": 5960,
    "questionResults": [
      {
        "questionIndex": 0,
        "questionText": "Resuelve para x: 2x + 4 = 14",
        "isCorrect": true,
        "answerText": ["x = 5"],
        "answerMediaID": [],
        "timeTakenMs": 4500,
      },
      {
        "questionIndex": 1,
        "questionText": "Simplifica la expresión: 3a + 5a - 2a",
        "isCorrect": true,
        "answerText": ["6a"],
        "answerMediaID": [],
        "timeTakenMs": 3200,
      },
      {
        "questionIndex": 2,
        "questionText": "¿Cuál de estos es un número primo?",
        "isCorrect": false,
        "answerText": ["9"],
        "answerMediaID": [],
        "timeTakenMs": 8100,
      },
      {
        "questionIndex": 3,
        "questionText": "Expande el binomio: (x + 1)²",
        "isCorrect": true,
        "answerText": ["x² + 2x + 1"],
        "answerMediaID": [],
        "timeTakenMs": 5000,
      },
      {
        "questionIndex": 4,
        "questionText":
            "Selecciona la fórmula correcta del Teorema de Pitágoras",
        "isCorrect": true,
        "answerText": [],
        "answerMediaID": [
          "https://cdn.example.com/math/pythagoras-theorem.png",
        ],
        "timeTakenMs": 9000,
      },
    ],
  };

  Map<String, dynamic> get mockGeneralReport => {
    "reportId": "rep-uuid-99887766",
    "sessionId": "b1b2c3d4-e89b-12d3-a456-426614174002",
    "title": "Capitales de Europa - Desafío Final",
    "executionDate": "2025-10-25T14:30:00.000Z",
    "playerRanking": [
      {
        "position": 1,
        "username": "TuUsuario",
        "score": 12500,
        "correctAnswers": 4,
      },
      {
        "position": 2,
        "username": "AnaGamer",
        "score": 11200,
        "correctAnswers": 4,
      },
      {
        "position": 3,
        "username": "CarlosPro",
        "score": 9800,
        "correctAnswers": 3,
      },
      {
        "position": 4,
        "username": "Luisa123",
        "score": 5400,
        "correctAnswers": 2,
      },
      {
        "position": 5,
        "username": "Invitado_99",
        "score": 2100,
        "correctAnswers": 1,
      },
      {
        "position": 1,
        "username": "TuUsuario",
        "score": 12500,
        "correctAnswers": 4,
      },
      {
        "position": 2,
        "username": "AnaGamer",
        "score": 11200,
        "correctAnswers": 4,
      },
      {
        "position": 3,
        "username": "CarlosPro",
        "score": 9800,
        "correctAnswers": 3,
      },
      {
        "position": 4,
        "username": "Luisa123",
        "score": 5400,
        "correctAnswers": 2,
      },
      {
        "position": 5,
        "username": "Invitado_99",
        "score": 2100,
        "correctAnswers": 1,
      },
    ],
    "questionAnalysis": [
      {
        "questionIndex": 0,
        "questionText": "¿Cuál es la capital de Francia?",
        "correctPercentage": 0.95,
      },
      {
        "questionIndex": 1,
        "questionText": "¿Cuál es la capital de Alemania?",
        "correctPercentage": 0.75,
      },
      {
        "questionIndex": 2,
        "questionText": "Selecciona la bandera de Italia",
        "correctPercentage": 0.88,
      },
      {
        "questionIndex": 3,
        "questionText": "¿Cuál es la capital de España?",
        "correctPercentage": 0.92,
      },
      {
        "questionIndex": 0,
        "questionText": "¿Cuál es la capital de Francia?",
        "correctPercentage": 0.95,
      },
      {
        "questionIndex": 1,
        "questionText": "¿Cuál es la capital de Alemania?",
        "correctPercentage": 0.75,
      },
      {
        "questionIndex": 2,
        "questionText": "Selecciona la bandera de Italia",
        "correctPercentage": 0.88,
      },
      {
        "questionIndex": 3,
        "questionText": "¿Cuál es la capital de España?",
        "correctPercentage": 0.92,
      },
    ],
  };

  @override
  Future<PaginatedResult<Results>> findMyResults(
    ReportsFilterParams params,
  ) async {
    try {
      Map<String, dynamic> responseBody;
      if (params.page == 1) {
        responseBody = mockFindMyResults;
      } else {
        responseBody = mockFindMyResults2;
      }
      final List<dynamic> data = responseBody['results'];
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
      final Map<String, dynamic> paginationData = responseBody['meta'];
      final PaginatedResult<Results> paginatedResult = PaginatedResult(
        items: resultsList,
        totalCount: paginationData['totalItems'] as int,
        totalPages: paginationData['totalPages'] as int,
        currentPage: paginationData['currentPage'] as int,
        limit: paginationData['limit'] as int,
      );
      return paginatedResult;
    } catch (e) {
      print(e);
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
      //String path;
      Map<String, dynamic> mock = {};
      switch (gameType) {
        case GameType.multiplayer:
          {
            //path=/reports/multiplayer/:sessionid
            mock = mockPersonalMultiplayerResults;
          }
        case GameType.singleplayer:
          {
            //fetch singleplayer data using attempt id
            mock = mockPersonalSingleplayerResults;
          }
      }
      final Map<String, dynamic> responseBody = mock;
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
            (item['answerMediaID'] as List<dynamic>?)
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
    } catch (e) {
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  Future<Report> getGeneralReport(String sessionId) async {
    try {
      //String path;

      final Map<String, dynamic> responseBody = mockGeneralReport;
      String reportId = responseBody['reportId'] as String;
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
        reportId: reportId,
        sessionId: sessionId,
        title: title,
        executionDate: executionDate,
        playerRanking: playerRanking,
        questionAnalysis: questionAnalysis,
      );
    } catch (e) {
      throw AppException(
        message: "Ocurrió un error inesperado",
        statusCode: 500,
        error: e.toString(),
      );
    }
  }
}

void main(List<String> args) {
  FakeReportRepositoryImpl repo = FakeReportRepositoryImpl();
  // repo
  //     .findMyResults(ReportsFilterParams(page: 1, limit: 10, order: 'desc'))
  //     .then((value) {
  //       print('Total Results: ${value.totalCount}');
  //       for (var result in value.items) {
  //         print(
  //           'Title: ${result.title}, Score: ${result.finalScore}, Date: ${result.completionDate}',
  //         );
  //         if (result.rankingPosition != null) {
  //           print('Ranking Position: ${result.rankingPosition}');
  //         } else {
  //           print('No ranking position available');
  //         }
  //       }
  //     })
  //     .catchError((error) {
  //       print('Error: $error');
  //     });

  // repo
  //     .getPersonalResult(
  //       '223e4567-e89b-12d3-a456-426614174002',
  //       GameType.singleplayer,
  //     )
  //     .then((personalResult) {
  //       print('Personal Result for Kahoot ID: ${personalResult.kahootId}');
  //       print('Title: ${personalResult.title}');
  //       print('Final Score: ${personalResult.finalScore}');
  //       print(
  //         'Correct Answers: ${personalResult.correctAnswers}/${personalResult.totalQuestions}',
  //       );
  //       print('Ranking Position: ${personalResult.rankingPosition ?? "N/A"}');
  //       print('Average Time (ms): ${personalResult.averageTimeMs}');
  //       for (var question in personalResult.questionResults) {
  //         print(
  //           'Question ${question.questionIndex + 1}: ${question.questionText}',
  //         );
  //         print('  Is Correct: ${question.isCorrect}');
  //         print('  Answer Text: ${question.answerText.join(", ")}');
  //         print('  Answer Media IDs: ${question.answerMediaId.join(", ")}');
  //         print('  Time Taken (ms): ${question.timeTakenMs}');
  //       }
  //     })
  //     .catchError((error) {
  //       print('Error: $error');
  //     });

  repo
      .getGeneralReport('b1b2c3d4-e89b-12d3-a456-426614174002')
      .then((report) {
        print('General Report for Session ID: ${report.sessionId}');
        print('Title: ${report.title}');
        print('Execution Date: ${report.executionDate}');
        print('Player Ranking:');
        for (var player in report.playerRanking) {
          print(
            '  Position: ${player.position}, Username: ${player.username}, Score: ${player.score}, Correct Answers: ${player.correctAnswers}',
          );
        }
        print('Question Analysis:');
        for (var question in report.questionAnalysis) {
          print(
            '  Question ${question.questionIndex + 1}: ${question.questionText}, Correct Percentage: ${question.correctPercentage * 100}%',
          );
        }
      })
      .catchError((error) {
        print('Error: $error');
      });
}
