
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/current_question.dart';
import 'package:frontkahoot2526/features/games/multiplayer/domain/multiplayer_game_repository.dart';

class SubmitAnswerUseCase {
  final IMultiplayerGameRepository repository;
  //instancia del repositorio para auth

  SubmitAnswerUseCase(this.repository);

  Future<void> execute(CurrentQuestion question, List<String> answerIds, int timeElapsedMs) {

    if(answerIds.isEmpty || answerIds.any((id) => !question.options.any((option) => option.answerIndex == id))) {
      throw AppException(message: 'Índice de respuesta inválido');
    }
    return repository.submitAnswer(
      answerIds,
      question.questionId,
      timeElapsedMs,
    );
  }
}