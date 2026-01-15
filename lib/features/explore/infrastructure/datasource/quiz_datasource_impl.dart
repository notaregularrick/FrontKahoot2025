import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../models/quiz_model.dart';
import 'quiz_datasource.dart';

class QuizDatasourceImpl implements QuizDatasource {
  final Dio dio;
  QuizDatasourceImpl(this.dio);

  @override
  Future<QuizModel> getQuizDetail(String id) async {
    // El endpoint individual no existe en el backend.
    // La aplicación confía en que los datos se pasan desde la pantalla /explore.
    // Si se intenta cargar individualmente (ej. sin pasar el objeto 'extra'), fallará controladamente.
    throw Exception("El backend no soporta buscar quiz por ID ($id). Los datos deben venir de /explore.");
  }
}

final quizDatasourceProvider = Provider<QuizDatasource>((ref) {
  final dio = ref.read(apiServiceProvider).dio;
  return QuizDatasourceImpl(dio);
});