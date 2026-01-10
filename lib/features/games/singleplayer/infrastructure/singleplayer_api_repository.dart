import 'package:dio/dio.dart';

class SingleplayerApiRepository {
  final Dio _dio;
  SingleplayerApiRepository(this._dio);

  Future<Map<String, dynamic>> createAttempt(String kahootId) async {
    final res = await _dio.post(
      '/attempts',
      data: {'kahootId': kahootId},
    );
    // ignore: avoid_print
    print('[attempts][create] status=${res.statusCode} body=${res.data}');
    final map = _unwrapMap(res.data);
    return {
      'attemptId': map['attemptId']?.toString(),
      'firstSlide': map['firstSlide'] != null ? _mapSlide(map['firstSlide']) : null,
    };
  }

  Future<Map<String, dynamic>?> getAttempt(String attemptId) async {
    final res = await _dio.get('/attempts/$attemptId');
    // ignore: avoid_print
    print('[attempts][get] id=$attemptId status=${res.statusCode} body=${res.data}');
    final map = _unwrapMap(res.data);
    return {
      'attemptId': map['attemptId']?.toString() ?? attemptId,
      'state': map['state']?.toString(),
      'currentScore': _toInt(map['currentScore']),
      'nextSlide': map['nextSlide'] != null ? _mapSlide(map['nextSlide']) : null,
    };
  }

  Future<Map<String, dynamic>?> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndexes,
    required int timeElapsedSeconds,
  }) async {
    final res = await _dio.post(
      '/attempts/$attemptId/answer',
      data: {
        'slideId': slideId,
        'answerIndex': answerIndexes,
        'timeElapsedSeconds': timeElapsedSeconds,
      },
    );
    // ignore: avoid_print
    print('[attempts][answer] id=$attemptId status=${res.statusCode} body=${res.data}');
    final map = _unwrapMap(res.data);
    return {
      'wasCorrect': map['wasCorrect'] ?? map['correct'] ?? map['isCorrect'],
      'pointsEarned': _toInt(map['pointsEarned'] ?? map['pointsGained']),
      'updatedScore': _toInt(map['updatedScore'] ?? map['currentScore']),
      'attemptState': map['attemptState']?.toString() ?? map['state']?.toString(),
      'nextSlide': map['nextSlide'] != null ? _mapSlide(map['nextSlide']) : null,
    };
  }

  Future<Map<String, dynamic>?> getSummary(String attemptId) async {
    final res = await _dio.get('/attempts/$attemptId/summary');
    final map = _unwrapMap(res.data);
    return {
      'attemptId': map['attemptId']?.toString() ?? attemptId,
      'finalScore': _toInt(map['finalScore']),
      'totalCorrect': _toInt(map['totalCorrect']),
      'totalQuestions': _toInt(map['totalQuestions']),
      'accuracyPercentage': _toInt(map['accuracyPercentage']),
    };
  }

  Map<String, dynamic> _mapSlide(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    final optionsRaw = map['options'] as List? ?? <dynamic>[];
    final options = optionsRaw.map((o) {
      final omap = Map<String, dynamic>.from(o as Map);
      return {
        'index': _toInt(omap['index']),
        'text': omap['text']?.toString(),
        'mediaUrl': omap['mediaID']?.toString() ?? omap['mediaUrl']?.toString(),
      };
    }).toList();

    return {
      'slideId': map['slideId']?.toString() ?? map['id']?.toString() ?? '',
      'questionType': map['questionType']?.toString() ?? '',
      'questionText': map['questionText']?.toString() ?? '',
      'timeLimitSeconds': _toInt(map['timeLimitSeconds']),
      'mediaUrl': map['mediaID']?.toString() ?? map['mediaUrl']?.toString(),
      'options': options,
    };
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) return Map<String, dynamic>.from(data['data'] as Map<String, dynamic>);
      return Map<String, dynamic>.from(data);
    }
    throw DioException(requestOptions: RequestOptions(path: ''), error: 'Unexpected map response shape');
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
