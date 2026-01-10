import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/answer.dart';
import 'package:frontkahoot2526/core/domain/entities/question.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/create_kahoot/domain/create_quiz_repository.dart';

class CreateQuizRepositoryImpl implements ICreateQuizRepository {
  final Dio _dio;

  CreateQuizRepositoryImpl(this._dio);

  @override
  Future<Quiz> createQuiz(Quiz quiz) async {
    try {
      // Convertir entidad Quiz a JSON camelCase
      final jsonData = _quizToJson(quiz);

      // Realizar POST request
      final response = await _dio.post(
        '/kahoots',
        data: jsonData,
      );

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
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        String message = 'Error al crear el quiz';
        
        if (statusCode == 400) {
          message = 'Datos del quiz inválidos';
        } else if (statusCode == 401) {
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
        throw AppException(
          message: 'Error de conexión al crear el quiz',
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
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

  /// Convierte entidad Quiz a JSON camelCase 
  Map<String, dynamic> _quizToJson(Quiz quiz) {
    // Helper para pasar URL o null si está vacío
    String? _urlOrNull(String? url) {
      if (url == null || url.isEmpty) return null;
      return url; // Pasar la URL directamente sin transformar
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
              answerJson['mediaId'] = _urlOrNull(answer.mediaId);
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
        questionJson['mediaId'] = _urlOrNull(question.mediaId);
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
    json['coverImageId'] = _urlOrNull(quiz.coverImageId);
    
    json['category'] = (quiz.category.isEmpty) ? null : quiz.category;
    json['questions'] = questionsJson;

    return json;
  }

  /// Convierte respuesta JSON a entidad Quiz
  Quiz _quizFromJson(Map<String, dynamic> json) {
    // Helper para extraer mediaId de una URL completa
    String? _urlToMediaId(String? url) {
      if (url == null || url.isEmpty) return null;
      // Si ya es solo un ID (sin /), retornarlo tal cual
      if (!url.contains('/')) return url;
      // Extraer el ID de la URL (último segmento después de /media/)
      try {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        final mediaIndex = pathSegments.indexOf('media');
        if (mediaIndex != -1 && mediaIndex < pathSegments.length - 1) {
          return pathSegments[mediaIndex + 1];
        }
        // Si no encuentra /media/, tomar el último segmento
        return pathSegments.isNotEmpty ? pathSegments.last : null;
      } catch (e) {
        // Si falla el parsing, retornar null
        return null;
      }
    }

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
              mediaId: _urlToMediaId(aJson['mediaId']?.toString()),
            );
          }).toList();
        }

        return Question(
          id: qJson['id']?.toString() ?? '',
          text: qJson['text']?.toString() ?? '',
          type: _mapQuestionTypeFromApi(qJson['type']?.toString() ?? 'quiz'),
          timeLimit: qJson['timeLimit'] ?? 0,
          points: qJson['points'] ?? 0,
          mediaId: _urlToMediaId(qJson['mediaId']?.toString()),
          answers: answers,
        );
      }).toList();
    }

    return Quiz(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImageId: _urlToMediaId(json['coverImageId']?.toString()),
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

