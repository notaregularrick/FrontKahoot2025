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
    print('Iniciando generación de quiz');
    print('Parámetros recibidos:');
    print('Prompt: "${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}${prompt.length > 50 ? '...' : ''}"');
    print('Título: "$title"');
    print('Descripción: "${description.substring(0, description.length > 30 ? 30 : description.length)}${description.length > 30 ? '...' : ''}"');
    print('Categoría: $category');
    print('Número de preguntas: $numberOfQuestions');
    print('API Key configurada: ${_apiKey.length > 10 ? _apiKey.substring(0, 10) + '...' : _apiKey}');
    
    try {
      print('Construyendo prompt');
      final promptText = _buildPrompt(
        prompt: prompt,
        title: title,
        description: description,
        category: category,
        numberOfQuestions: numberOfQuestions,
      );
      print('Prompt construido (${promptText.length} caracteres)');

      // Validar que la API key no esté vacía
      if (_apiKey.isEmpty) {
        print('ERROR: API key vacía');
        throw AppException(
          message: 'API key vacía',
          statusCode: 401,
          error: 'Empty API key',
        );
      }
      
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';
      print('URL de API: https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=***');
      print('Método: POST');
      print('Headers: Content-Type: application/json');
      
      // Validar formato de URL
      if (!url.startsWith('https://')) {
        print('ERROR: URL inválida');
        throw AppException(
          message: 'URL inválida',
          statusCode: 500,
          error: 'Invalid URL format',
        );
      }
      print('Timeout configurado: 30 segundos');
      //llamada a la API con dio
      print('Enviando request a Gemini API');
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

      print('Respuesta recibida: ${response.statusCode}');
      final responseSize = response.data.toString().length;
      print('Tamaño de respuesta: $responseSize caracteres');
      
      if (response.statusCode == 200) {
        print('Validando estructura de respuesta...');
        final responseData = response.data;
        final candidates = responseData['candidates'] as List?;
        
        print('Candidates encontrados: ${candidates?.length ?? 0}');
        if (candidates == null || candidates.isEmpty) {
          print('ERROR: No se encontraron candidates en la respuesta');
          print('Estructura de respuesta: ${responseData.keys.toList()}');
          throw AppException(
            message: 'La IA no generó una respuesta válida',
            statusCode: 500,
            error: 'No candidates found in response',
          );
        }

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;
        
        print('Parts encontrados: ${parts?.length ?? 0}');
        if (parts == null || parts.isEmpty) {
          print('ERROR: No se encontraron parts en el contenido');
          print('Estructura del content: ${content?.keys.toList()}');
          throw AppException(
            message: 'La respuesta de la IA no contiene contenido',
            statusCode: 500,
            error: 'No parts found in content',
          );
        }

        final text = parts[0]['text'] as String?;
        final textPreview = text != null && text.isNotEmpty 
            ? text.substring(0, text.length > 200 ? 200 : text.length)
            : 'null';
        print('Texto extraído: ${textPreview}${text != null && text.length > 200 ? '...' : ''}');
        print('Longitud del texto: ${text?.length ?? 0} caracteres');
        
        if (text == null || text.isEmpty) {
          print('[AI_REPO] ❌ ERROR: El texto extraído está vacío o es null');
          throw AppException(
            message: 'La IA no generó texto en la respuesta',
            statusCode: 500,
            error: 'Empty or null text in response',
          );
        }

        print('Iniciando parsing de respuesta...');
        return _parseAIResponse(text, title, description, category);
      } else {
        print('ERROR: Status code inesperado: ${response.statusCode}');
        print('Respuesta: ${response.data}');
        throw AppException(
          message: 'Error al generar el quiz con IA',
          statusCode: response.statusCode ?? 500,
          error: 'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        String message = 'Error al generar el quiz con IA';
        String errorDetails = '';
        
        print('ERROR HTTP ${statusCode}');
        
        if (statusCode == 400) {
          message = 'Solicitud inválida a la IA - Verificar formato del prompt o parámetros';
          errorDetails = 'Bad Request - La solicitud tiene un formato incorrecto';
          print('[AI_REPO] 🔍 CAUSA: Solicitud inválida - Verificar formato del prompt o parámetros');
        } else if (statusCode == 401) {
          message = 'API key inválida o expirada. Verificar API key en Google AI Studio';
          errorDetails = 'Unauthorized. La API key no es válida o ha expirado';
          print('API key inválida o expirada. Verificar API key en Google AI Studio');
        } else if (statusCode == 429) {
          message = 'Límite de solicitudes excedido - Esperar antes de reintentar';
          errorDetails = 'Rate Limit Exceeded - Se excedió el límite de solicitudes por minuto';
          print('Límite de solicitudes excedido - Esperar antes de reintentar');
        } else if (statusCode == 404) {
          message = 'Modelo no encontrado. El modelo gemini-2.5-flash podría no estar disponible. Verificar modelos disponibles en Google AI Studio';
          errorDetails = 'Not Found - El endpoint o modelo no existe';
          print('Endpoint no encontrado (404)');
          print('URL utilizada: https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=***');
          print('SUGERENCIA: Verificar que el modelo "gemini-2.5-flash" esté disponible');
          print('SUGERENCIA: Si no está disponible, intentar con "gemini-2.0-flash-exp" o "gemini-1.5-pro"');
          print(' SUGERENCIA: Verificar documentación actualizada de Gemini API en https://ai.google.dev/models/gemini');
        } else if (statusCode == 500) {
          message = 'Error en servidor de Gemini. Intentar más tarde';
          errorDetails = 'Internal Server Error. Error en el servidor de Gemini';
          print('Error en servidor de Gemini. Intentar más tarde');
        } else {
          errorDetails = 'HTTP Error ${statusCode}';
          print('Error HTTP desconocido. Status code: $statusCode');
        }
        
        final responseData = e.response?.data?.toString() ?? 'No response data';
        print('Respuesta del servidor: $responseData');
        
        throw AppException(
          message: message,
          statusCode: statusCode,
          error: errorDetails + (responseData.isNotEmpty ? ' - Response: $responseData' : ''),
        );
      } else {
        print('ERROR de conexión: ${e.message}');
        print('Error de red o timeout. Verificar conexión a internet');
        if (e.type == DioExceptionType.connectionTimeout) {
          print('Tipo: Connection Timeout');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          print('Tipo: Receive Timeout');
        } else if (e.type == DioExceptionType.sendTimeout) {
          print('Tipo: Send Timeout');
        }
        throw AppException(
          message: 'Error de conexión al generar el quiz con IA',
          statusCode: 500,
          error: e.message ?? 'Network error',
        );
      }
    } catch (e, stackTrace) {
      if (e is AppException) {
        print('Relanzando AppException: ${e.message}');
        rethrow;
      }
      print('ERROR INESPERADO: ${e.toString()}');
      print('Tipo de error: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
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
    print('Construyendo prompt con parámetros:');
    print('Tema: "$prompt"');
    print('Título: "$title"');
    print('Número de preguntas: $numberOfQuestions');
    
    final promptText = '''
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
    
    print('Prompt construido (${promptText.length} caracteres)');
    return promptText;
  }

  Quiz _parseAIResponse(
    String responseText,
    String title,
    String description,
    String category,
  ) {
    print('Iniciando parsing de respuesta');
    
    try {
      // Limpiar la respuesta para extraer solo el JSON
      String jsonString = responseText.trim();
      print('Paso 1: Texto trimado (${jsonString.length} caracteres)');
      
      // Remover markdown code blocks si existen
      final beforeMarkdown = jsonString.length;
      jsonString = jsonString.replaceAll(RegExp(r'```json\s*'), '');
      jsonString = jsonString.replaceAll(RegExp(r'```\s*'), '');
      if (jsonString.length != beforeMarkdown) {
        print('Paso 2: Markdown removido (${jsonString.length} caracteres)');
      }
      
      // Buscar el inicio del JSON (primer {)
      final jsonStart = jsonString.indexOf('{');
      if (jsonStart != -1) {
        print('Paso 3: Inicio de JSON encontrado en posición $jsonStart');
        jsonString = jsonString.substring(jsonStart);
      } else {
        print('ADVERTENCIA: No se encontró inicio de JSON ({)');
      }
      
      // Buscar el final del JSON (último })
      final jsonEnd = jsonString.lastIndexOf('}');
      if (jsonEnd != -1) {
        print('Paso 4: Fin de JSON encontrado en posición $jsonEnd');
        jsonString = jsonString.substring(0, jsonEnd + 1);
        print('JSON extraído: ${jsonString.length} caracteres');
      } else {
        print('ADVERTENCIA: No se encontró fin de JSON (})');
      }

      print('Decodificando JSON');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      print('JSON decodificado exitosamente');
      print('Claves encontradas en JSON: ${jsonData.keys.toList()}');
      
      // Convertir a entidad Quiz
      print('Convirtiendo JSON a entidad Quiz');
      final questions = <Question>[];
      
      if (jsonData['questions'] == null) {
        print('ERROR: Campo "questions" no encontrado en JSON');
        print('Campos disponibles: ${jsonData.keys.toList()}');
        throw AppException(
          message: 'La IA no generó preguntas válidas. Campo "questions" no encontrado',
          statusCode: 500,
          error: 'Missing "questions" field in JSON response',
        );
      }
      
      if (jsonData['questions'] is! List) {
        print('ERROR: Campo "questions" no es una lista');
        print('Tipo de "questions": ${jsonData['questions'].runtimeType}');
        throw AppException(
          message: 'La IA no generó preguntas válidas - Campo "questions" no es una lista',
          statusCode: 500,
          error: 'Invalid type for "questions" field',
        );
      }
      
      final questionsList = jsonData['questions'] as List;
      print('Preguntas encontradas en JSON: ${questionsList.length}');
      
      for (int i = 0; i < questionsList.length; i++) {
        print('Procesando pregunta ${i + 1}/${questionsList.length}...');
        
        if (questionsList[i] is! Map<String, dynamic>) {
          print('ADVERTENCIA: Pregunta $i no es un objeto válido');
          continue;
        }
        
        final qData = questionsList[i] as Map<String, dynamic>;
        print('Texto: "${(qData['text']?.toString() ?? '').substring(0, (qData['text']?.toString() ?? '').length > 40 ? 40 : (qData['text']?.toString() ?? '').length)}${(qData['text']?.toString() ?? '').length > 40 ? '...' : ''}"');
        
        final answers = <Answer>[];
        if (qData['answers'] != null && qData['answers'] is List) {
          final answersList = qData['answers'] as List;
          print('Respuestas encontradas: ${answersList.length}');
          
          for (int j = 0; j < answersList.length; j++) {
            if (answersList[j] is! Map<String, dynamic>) {
              print('ADVERTENCIA: Respuesta $j no es un objeto válido');
              continue;
            }
            
            final aData = answersList[j] as Map<String, dynamic>;
            final answerText = aData['text']?.toString() ?? '';
            final isCorrect = aData['isCorrect'] == true;
            print('Respuesta $j: "${answerText.substring(0, answerText.length > 30 ? 30 : answerText.length)}${answerText.length > 30 ? '...' : ''}" (Correcta: $isCorrect)');
            
            answers.add(Answer(
              id: 'answer_${i}_$j',
              text: answerText.isEmpty ? null : answerText,
              isCorrect: isCorrect,
              mediaId: null,
            ));
          }
        } else {
          print('ADVERTENCIA: Pregunta $i no tiene respuestas válidas');
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
        
        print('Pregunta ${i + 1} procesada: ${answers.length} respuestas');
      }

      if (questions.isEmpty) {
        print('ERROR: No se pudieron parsear preguntas válidas');
        print('JSON recibido (primeros 500 caracteres): ${jsonString.substring(0, jsonString.length > 500 ? 500 : jsonString.length)}${jsonString.length > 500 ? '...' : ''}');
        throw AppException(
          message: 'La IA no generó preguntas válidas',
          statusCode: 500,
          error: 'No valid questions parsed from response',
        );
      }
      
      print('Total preguntas parseadas: ${questions.length}');

      print('Creando entidad Quiz');
      final quiz = Quiz(
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
      
      print('Quiz creado exitosamente');
      
      return quiz;
    } catch (e, stackTrace) {
      if (e is AppException) {
        print('AppException durante parsing: ${e.message}');
        rethrow;
      }
      
      print('ERROR al interpretar respuesta: ${e.toString()}');
      print(' Tipo de error: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      
      // Mostrar parte del texto que causó el error
      final errorPreview = responseText.length > 500 
          ? responseText.substring(0, 500) 
          : responseText;
      print('Texto que causó el error: $errorPreview${responseText.length > 500 ? '...' : ''}');
      
      throw AppException(
        message: 'Error al interpretar la respuesta de la IA: ${e.toString()}',
        statusCode: 500,
        error: 'Parsing error: ${e.toString()}',
      );
    }
  }
}


