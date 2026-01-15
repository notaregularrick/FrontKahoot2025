import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/answer.dart';
import 'package:frontkahoot2526/core/domain/entities/question.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/create_kahoot/domain/create_quiz_repository.dart';

class CreateQuizRepositoryImpl implements ICreateQuizRepository {
  final Dio _dio;

  CreateQuizRepositoryImpl(this._dio);

  String? _extractMediaId(String? urlOrId) {
    if (urlOrId == null || urlOrId.isEmpty) return null;
    if (!urlOrId.contains('/')) return urlOrId;
    try {
      final uri = Uri.parse(urlOrId);
      final segments = uri.pathSegments;
      final mediaIndex = segments.indexOf('media');
      if (mediaIndex != -1 && mediaIndex < segments.length - 1) {
        return segments[mediaIndex + 1];
      }
      return segments.isNotEmpty ? segments.last : urlOrId;
    } catch (_) {
      return urlOrId;
    }
  }

  @override
  Future<Quiz> createQuiz(Quiz quiz) async {
    try {
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [CREATE QUIZ] Iniciando creación de quiz...');
      print('╠══════════════════════════════════════════════════════════════');
      
      // Convertir entidad Quiz a JSON camelCase
      final jsonData = _quizToJson(quiz);

      // Imprimir JSON completo formateado
      final jsonPretty = const JsonEncoder.withIndent('  ').convert(jsonData);
      print('║ [CREATE QUIZ] JSON a enviar:');
      print('║ $jsonPretty');
      print('╠══════════════════════════════════════════════════════════════');
      print('║ [CREATE QUIZ] URL base: ${_dio.options.baseUrl}');
      print('║ [CREATE QUIZ] Endpoint: POST /kahoots');
      print('╠══════════════════════════════════════════════════════════════');

      // Realizar POST request
      //llamada al backend con dio
      final response = await _dio.post(
        '/kahoots',
        data: jsonData,
      );

      print('║ [CREATE QUIZ] Respuesta recibida - Status: ${response.statusCode}');
      print('║ [CREATE QUIZ] Response data: ${response.data}');
      print('╚══════════════════════════════════════════════════════════════');

      // Validar respuesta
      if (response.statusCode == 201) {
        return _quizFromJson(response.data);
      } else {
        throw AppException(
          message: 'Error al crear el quiz',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      print('║ [CREATE QUIZ] ❌ DioException capturada');
      print('║ [CREATE QUIZ] Tipo: ${e.type}');
      print('║ [CREATE QUIZ] Mensaje: ${e.message}');
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response?.data;
        
        print('║ [CREATE QUIZ] Status code: $statusCode');
        print('║ [CREATE QUIZ] Response data: $responseData');
        print('╚══════════════════════════════════════════════════════════════');
        
        String message = 'Datos del quiz inválidos';
        
        if (statusCode == 401) {
          message = 'No autorizado';
        } else if (statusCode == 404) {
          message = 'El recurso no existe o no es accesible';
        }
        
        throw AppException(
          message: message,
          statusCode: statusCode,
          error: e.response?.data?.toString(),
        );
      } else {
        print('║ [CREATE QUIZ] Sin respuesta del servidor');
        print('╚══════════════════════════════════════════════════════════════');
        
        throw AppException(
          message: 'Error de conexión al crear el quiz',
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
      print('║ [CREATE QUIZ] ❌ Excepción no manejada: ${e.runtimeType}');
      print('║ [CREATE QUIZ] Mensaje: $e');
      print('╚══════════════════════════════════════════════════════════════');
      
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error inesperado al crear el quiz',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  @override
  Future<Quiz> getQuiz(String quizId) async {
    try {
      print('║ [GET QUIZ] URL base: ${_dio.options.baseUrl}');
      print('║ [GET QUIZ] Endpoint: GET /kahoots/$quizId');
      final response = await _dio.get('/kahoots/$quizId');
      if (response.statusCode == 200) {
        return _quizFromJson(response.data);
      }
      throw AppException(
        message: 'Error al obtener el quiz',
        statusCode: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw AppException(
          message: 'No se pudo obtener el quiz',
          statusCode: e.response?.statusCode ?? 500,
          error: e.response?.data?.toString(),
        );
      }
      throw AppException(
        message: 'Error de conexión al obtener el quiz',
        statusCode: 500,
        error: e.message,
      );
    }
  }

  @override
  Future<Quiz> updateQuiz(String quizId, Quiz quiz) async {
    try {
      print('╔══════════════════════════════════════════════════════════════');
      print('║ [UPDATE QUIZ] Iniciando actualización de quiz...');
      print('╠══════════════════════════════════════════════════════════════');
      final jsonData = _quizToJson(quiz);
      final jsonPretty = const JsonEncoder.withIndent('  ').convert(jsonData);
      print('║ [UPDATE QUIZ] JSON a enviar:');
      print('║ $jsonPretty');
      print('╠══════════════════════════════════════════════════════════════');
      print('║ [UPDATE QUIZ] URL base: ${_dio.options.baseUrl}');
      print('║ [UPDATE QUIZ] Endpoint: PUT /kahoots/$quizId');
      print('╠══════════════════════════════════════════════════════════════');

      final response = await _dio.put(
        '/kahoots/$quizId',
        data: jsonData,
      );

      print('║ [UPDATE QUIZ] Respuesta recibida - Status: ${response.statusCode}');
      print('║ [UPDATE QUIZ] Response data: ${response.data}');
      print('╚══════════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        return _quizFromJson(response.data);
      } else {
        throw AppException(
          message: 'Error al actualizar el quiz',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      print('║ [UPDATE QUIZ] ❌ DioException capturada');
      print('║ [UPDATE QUIZ] Tipo: ${e.type}');
      print('║ [UPDATE QUIZ] Mensaje: ${e.message}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response?.data;
        print('║ [UPDATE QUIZ] Status code: $statusCode');
        print('║ [UPDATE QUIZ] Response data: $responseData');
        print('╚══════════════════════════════════════════════════════════════');
        String message = 'Datos del quiz inválidos';
        if (statusCode == 401) message = 'No autorizado';
        if (statusCode == 404) message = 'El quiz no existe';
        throw AppException(
          message: message,
          statusCode: statusCode,
          error: e.response?.data?.toString(),
        );
      } else {
        throw AppException(
          message: 'Error de conexión al actualizar el quiz',
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Error inesperado al actualizar el quiz',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  /// Convierte entidad Quiz a JSON camelCase 
  Map<String, dynamic> _quizToJson(Quiz quiz) {
    // Helper para pasar ID o null si está vacío
    String? _idOrNull(String? id) {
      if (id == null || id.isEmpty) return null;
      final extracted = _extractMediaId(id);
      return extracted ?? id; // Preferir ID limpio, fallback al valor original
    }

    // Mapear tipo de pregunta: "quiz" -> "single", "multiple" -> "multiple", "true_false" -> "true_false"
    String _mapQuestionTypeToApi(String type) {
      switch (type) {
        case 'quiz':
          return 'single';
        case 'multiple':
          return 'multiple';
        case 'true_false':
          return 'true_false';
        default:
          return type; // Por si acaso hay otros tipos
      }
    }

    // Mapear visibility: "private" -> "Private", "public" -> "Public"
    String _mapVisibilityToApi(String visibility) {
      switch (visibility.toLowerCase()) {
        case 'private':
          return 'Private';
        case 'public':
          return 'Public';
        default:
          return visibility; // Mantener si ya está capitalizado
      }
    }

    // Mapear status: "draft" -> "Draft", "published" -> "Publish"
    String _mapStatusToApi(String status) {
      switch (status.toLowerCase()) {
        case 'draft':
          return 'Draft';
        case 'published':
          return 'Publish';
        default:
          return status; // Mantener si ya está capitalizado
      }
    }

    // Convertir questions a JSON
    List<Map<String, dynamic>>? questionsJson;
    if (quiz.questions.isEmpty) {
      questionsJson = null; // Array opcional puede ser null
    } else {
      questionsJson = quiz.questions.map((question) {
        // Convertir answers a JSON
        List<Map<String, dynamic>>? answersJson;
        if (question.answers.isEmpty) {
          answersJson = null; // Array opcional puede ser null
        } else {
          answersJson = question.answers.map((answer) {
            final answerJson = <String, dynamic>{};
            
            // Si tiene mediaId (URL), text debe ser null
            if (answer.mediaId != null && answer.mediaId!.isNotEmpty) {
              answerJson['mediaId'] = _idOrNull(answer.mediaId);
              answerJson['text'] = null;
            } else if (answer.text != null && answer.text!.isNotEmpty) {
              answerJson['text'] = answer.text;
              answerJson['mediaId'] = null;
            } else {
              // Si no tiene ni text ni mediaId, no incluir isCorrect
              return null; // Skip esta respuesta
            }
            
            // isCorrect solo existe si hay text O mediaId
            answerJson['isCorrect'] = answer.isCorrect;
            
            return answerJson;
          }).where((a) => a != null).cast<Map<String, dynamic>>().toList();
          
          // Si después de filtrar no hay respuestas, poner null
          if (answersJson.isEmpty) {
            answersJson = null;
          }
        }

        final questionJson = <String, dynamic>{
          'type': _mapQuestionTypeToApi(question.type),
          'timeLimit': question.timeLimit,
        };

        // Campos opcionales: null si están vacíos o no existen
        questionJson['text'] = (question.text.isEmpty) ? null : question.text;
        questionJson['mediaId'] = _idOrNull(question.mediaId);
        questionJson['points'] = question.points; // Puede ser null según especificación
        questionJson['answers'] = answersJson;

        return questionJson;
      }).toList();
    }

    // Construir JSON del quiz
    final json = <String, dynamic>{
      'visibility': _mapVisibilityToApi(quiz.visibility),
      'themeId': quiz.themeId,
      'status': _mapStatusToApi(quiz.status),
    };

    // Campos opcionales: null si están vacíos
    json['title'] = (quiz.title.isEmpty) ? null : quiz.title;
    json['description'] = (quiz.description.isEmpty) ? null : quiz.description;
    
    // coverImageId: URL completa o null (se pasa directamente)
    json['coverImageId'] = _idOrNull(quiz.coverImageId);
    
    json['category'] = (quiz.category.isEmpty) ? null : quiz.category;
    json['questions'] = questionsJson;

    return json;
  }

  /// Convierte respuesta JSON a entidad Quiz
  Quiz _quizFromJson(Map<String, dynamic> json) {
    // Helper para extraer mediaId de una URL completa
    // Mapear tipo de pregunta de API a dominio: "single" -> "quiz", "multiple" -> "multiple", "true_false" -> "true_false"
    String _mapQuestionTypeFromApi(String type) {
      switch (type) {
        case 'single':
          return 'quiz';
        case 'multiple':
          return 'multiple';
        case 'true_false':
          return 'true_false';
        default:
          return type;
      }
    }

    // Mapear visibility de API a dominio: "Private" -> "private", "Public" -> "public"
    String _mapVisibilityFromApi(String visibility) {
      switch (visibility) {
        case 'Private':
          return 'private';
        case 'Public':
          return 'public';
        default:
          return visibility.toLowerCase();
      }
    }

    // Mapear status de API a dominio: "Draft" -> "draft", "Publish" -> "published"
    String _mapStatusFromApi(String status) {
      switch (status) {
        case 'Draft':
          return 'draft';
        case 'Publish':
          return 'published';
        default:
          return status.toLowerCase();
      }
    }

    // Convertir questions de JSON
    List<Question> questions = [];
    if (json['questions'] != null && json['questions'] is List) {
      questions = (json['questions'] as List).map((qJson) {
        // Convertir answers de JSON
        List<Answer> answers = [];
        if (qJson['answers'] != null && qJson['answers'] is List) {
          answers = (qJson['answers'] as List).map((aJson) {
            return Answer(
              id: aJson['id']?.toString() ?? '',
              text: aJson['text']?.toString(),
              isCorrect: aJson['isCorrect'] ?? false,
              mediaId: _extractMediaId(aJson['mediaId']?.toString()),
            );
          }).toList();
        }

        return Question(
          id: qJson['id']?.toString() ?? '',
          text: qJson['text']?.toString() ?? '',
          type: _mapQuestionTypeFromApi(qJson['type']?.toString() ?? 'quiz'),
          timeLimit: qJson['timeLimit'] ?? 0,
          points: qJson['points'] ?? 0,
          mediaId: _extractMediaId(qJson['mediaId']?.toString()),
          answers: answers,
        );
      }).toList();
    }

    return Quiz(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImageId: json['coverImageId']?.toString(),
      visibility: _mapVisibilityFromApi(json['visibility']?.toString() ?? 'private'),
      status: _mapStatusFromApi(json['status']?.toString() ?? 'draft'),
      category: json['category']?.toString() ?? '',
      themeId: json['themeId']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      questions: questions,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      playCount: json['playCount'] ?? 0,
    );
  }
}

