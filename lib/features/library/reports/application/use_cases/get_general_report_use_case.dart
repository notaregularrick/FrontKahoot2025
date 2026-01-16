import 'package:frontkahoot2526/features/library/reports/domain/report.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_repository.dart';

class GetGeneralReportUseCase {
  final IReportsRepository repository;

  GetGeneralReportUseCase(this.repository);
  //falta obtener la url de la imagen y mostrarla
  Future<Report> execute(String sessionId){
    final report = repository.getGeneralReport(sessionId);
    report.then((value) => value.orderRanking());
    return report;
  }
}