import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../models/quiz_model.dart';
import 'mock_data.dart';
import 'quiz_datasource.dart';

class QuizDatasourceImpl implements QuizDatasource {
  final Dio dio;
  QuizDatasourceImpl(this.dio);

  @override
  Future<QuizModel> getQuizDetail(String id) async {
    // 1. LÓGICA DE INTERCEPCIÓN (Mocks)
    // Si el ID es uno de nuestros mocks, devolvemos el objeto local 
    // y evitamos la llamada a la red (que daría error 404/400).
    if (id == mockQuiz1.id) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simular carga
      return mockQuiz1;
    }
    
    if (id == mockQuiz2.id) {
      await Future.delayed(const Duration(milliseconds: 500));
      return mockQuiz2;
    }

    // 2. LÓGICA REAL (Backend)
    // Solo llegamos aquí si el ID no es de un mock
    try {
      print("Consultando API real para: $id");
      final response = await dio.get('/quizzes/$id');
      return QuizModel.fromJson(response.data);
    } catch (e) {
      // Re-lanzamos para que lo maneje el repositorio/notifier
      throw Exception('Error en QuizDatasource: $e');
    }
  }
}

final quizDatasourceProvider = Provider<QuizDatasource>((ref) {
  final dio = ref.read(apiServiceProvider).dio;
  return QuizDatasourceImpl(dio);
});