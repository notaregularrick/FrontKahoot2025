import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/answer.dart';
import 'package:frontkahoot2526/core/domain/entities/question.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/ai_quiz/domain/ai_quiz_repository.dart';

class AIQuizRepositoryImpl implements IAIQuizRepository {
  final Dio _dio;
  final String _apiKey;

  AIQuizRepositoryImpl({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  @override
  Future<Quiz> generateQuiz({
    required String prompt,
    required String title,
    required String description,
    required String category,
    int numberOfQuestions = 5,
  }) async {
    try {
      final promptText = _buildPrompt(
        prompt: prompt,
        title: title,
        description: description,
        category: category,
        numberOfQuestions: numberOfQuestions,
      );

      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

      final response = await _dio.post(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {'text': promptText}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final candidates = responseData['candidates'] as List?;
        
        if (candidates == null || candidates.isEmpty) {
          throw AppException(
            message: 'La IA no generó una respuesta válida',
            statusCode: 500,
          );
        }

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;
        
        if (parts == null || parts.isEmpty) {
          throw AppException(
            message: 'La respuesta de la IA no contiene contenido',
            statusCode: 500,
          );
        }

        final text = parts[0]['text'] as String?;
        
        if (text == null || text.isEmpty) {
          throw AppException(
            message: 'La IA no generó texto en la respuesta',
            statusCode: 500,
          );
        }

        return _parseAIResponse(text, title, description, category);
      } else {
        throw AppException(
          message: 'Error al generar el quiz con IA',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        String message = 'Error al generar el quiz con IA';
        
        if (statusCode == 400) {
          message = 'Solicitud inválida a la IA';
        } else if (statusCode == 401) {
          message = 'API key inválida o no autorizada';
        } else if (statusCode == 429) {
          message = 'Límite de solicitudes excedido. Por favor intenta más tarde';
        } else if (statusCode == 500) {
          message = 'Error en el servidor de IA';
        }
        
        throw AppException(
          message: message,
          statusCode: statusCode,
          error: e.response?.data?.toString(),
        );
      } else {
        throw AppException(
          message: 'Error de conexión al generar el quiz con IA',
          statusCode: 500,
          error: e.message,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error inesperado al generar el quiz: ${e.toString()}',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }

  String _buildPrompt({
    required String prompt,
    required String title,
    required String description,
    required String category,
    required int numberOfQuestions,
  }) {
    return '''
Eres un asistente experto en crear quizzes educativos y entretenidos. 
Genera un quiz completo en formato JSON estricto basado en el siguiente tema:

Tema/Prompt: $prompt
Título del Quiz: $title
Descripción: $description
Categoría: $category
Número de preguntas: $numberOfQuestions

IMPORTANTE: Debes responder ÚNICAMENTE con un objeto JSON válido, sin texto adicional antes o después, sin markdown, sin explicaciones.

El formato JSON debe ser exactamente así:

{
  "questions": [
    {
      "text": "Texto de la pregunta",
      "type": "quiz",
      "timeLimit": 20,
      "points": 1000,
      "answers": [
        {
          "text": "Opción 1",
          "isCorrect": true
        },
        {
          "text": "Opción 2",
          "isCorrect": false
        },
        {
          "text": "Opción 3",
          "isCorrect": false
        },
        {
          "text": "Opción 4",
          "isCorrect": false
        }
      ]
    }
  ]
}

REGLAS ESTRICTAS:
1. Genera exactamente $numberOfQuestions preguntas sobre el tema "$prompt"
2. Cada pregunta debe tener exactamente 4 respuestas (opciones)
3. Solo UNA respuesta debe ser correcta (isCorrect: true) por pregunta
4. Las preguntas deben ser claras, educativas y relacionadas con el tema
5. Las respuestas incorrectas deben ser plausibles pero incorrectas
6. El tipo de pregunta siempre debe ser "quiz" (no "true_false")
7. timeLimit debe ser 20 segundos para todas las preguntas
8. points debe ser 1000 para todas las preguntas
9. NO incluyas campos como "id", "mediaId" o "coverImageId" - solo los campos especificados
10. Responde SOLO con el JSON, sin explicaciones, sin markdown, sin código, sin backticks

Genera el quiz ahora:
''';
  }

  Quiz _parseAIResponse(
    String responseText,
    String title,
    String description,
    String category,
  ) {
    try {
      // Limpiar la respuesta para extraer solo el JSON
      String jsonString = responseText.trim();
      
      // Remover markdown code blocks si existen
      jsonString = jsonString.replaceAll(RegExp(r'```json\s*'), '');
      jsonString = jsonString.replaceAll(RegExp(r'```\s*'), '');
      
      // Buscar el inicio del JSON (primer {)
      final jsonStart = jsonString.indexOf('{');
      if (jsonStart != -1) {
        jsonString = jsonString.substring(jsonStart);
      }
      
      // Buscar el final del JSON (último })
      final jsonEnd = jsonString.lastIndexOf('}');
      if (jsonEnd != -1) {
        jsonString = jsonString.substring(0, jsonEnd + 1);
      }

      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      // Convertir a entidad Quiz
      final questions = <Question>[];
      if (jsonData['questions'] != null && jsonData['questions'] is List) {
        final questionsList = jsonData['questions'] as List;
        for (int i = 0; i < questionsList.length; i++) {
          final qData = questionsList[i] as Map<String, dynamic>;
          
          final answers = <Answer>[];
          if (qData['answers'] != null && qData['answers'] is List) {
            final answersList = qData['answers'] as List;
            for (int j = 0; j < answersList.length; j++) {
              final aData = answersList[j] as Map<String, dynamic>;
              answers.add(Answer(
                id: 'answer_${i}_$j',
                text: aData['text']?.toString(),
                isCorrect: aData['isCorrect'] == true,
                mediaId: null,
              ));
            }
          }

          questions.add(Question(
            id: 'question_$i',
            text: qData['text']?.toString() ?? '',
            type: qData['type']?.toString() ?? 'quiz',
            timeLimit: qData['timeLimit'] as int? ?? 20,
            points: qData['points'] as int? ?? 1000,
            mediaId: null,
            answers: answers,
          ));
        }
      }

      if (questions.isEmpty) {
        throw AppException(
          message: 'La IA no generó preguntas válidas',
          statusCode: 500,
        );
      }

      return Quiz(
        id: '',
        title: title,
        description: description,
        coverImageId: null,
        visibility: 'private',
        status: 'draft',
        category: category,
        themeId: '',
        authorId: '',
        authorName: '',
        questions: questions,
        createdAt: DateTime.now(),
        playCount: 0,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Error al parsear la respuesta de la IA: ${e.toString()}',
        statusCode: 500,
        error: e.toString(),
      );
    }
  }
}


