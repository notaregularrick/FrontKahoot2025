import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
import 'package:frontkahoot2526/features/library/reports/domain/personal_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/report.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_filter_params.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';

abstract class IReportsRepository {
  
  //H7.1 Quices creados y borradores
  Future<PaginatedResult<Results>> findMyResults(ReportsFilterParams params);

  Future<PersonalResult> getPersonalResult(String id, GameType gameType); //el id puede ser de session o attempt dependiendo del gameType

  Future<Report> getGeneralReport(String sessionId);

}