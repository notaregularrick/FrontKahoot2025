import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
import 'package:frontkahoot2526/features/library/reports/domain/personal_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_repository.dart';

class GetPersonalResultUseCase {
  final IReportsRepository repository;

  GetPersonalResultUseCase(this.repository);
  //falta obtener la url de la imagen y mostrarla
  Future<PersonalResult> execute(String gameId, GameType gameType) {
    return repository.getPersonalResult(gameId, gameType);
  }
}
