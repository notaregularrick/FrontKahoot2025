
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class SubmitAnswerUseCase {
  final IMultiplayerGameRepository repository;
  //instancia del repositorio para auth

  SubmitAnswerUseCase(this.repository);

  Future<void> execute(CurrentQuestion question, int answerIndex, int timeElapsedMs) {
    final String jwt = 'jwt-prueba'; //Aquí va lógica para obtener jwt

    if(answerIndex < 0 || answerIndex >= question.options.length) {
      throw AppException(message: 'Índice de respuesta inválido');
    }
    return repository.submitAnswer(question.questionId, answerIndex, timeElapsedMs, jwt);
  }
}