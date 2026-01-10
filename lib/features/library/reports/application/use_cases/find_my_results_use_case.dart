import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_filter_params.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_repository.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';

class FindMyResultsUseCase {
  final IReportsRepository repository;

  FindMyResultsUseCase(this.repository);
  //falta obtener la url de la imagen y mostrarla
  Future<PaginatedResult<Results>> execute(ReportsFilterParams params){
    return repository.findMyResults(params);
  } 
}

// void main(List<String> args) {
//   final repo = FakeReportRepositoryImpl();
//   final params = ReportsFilterParams();
//   final usecase = FindMyResultsUseCase(repo, params);
//   usecase.execute().then((value) {
//     for(final item in value.items){
//       print(item.title);
//     }
//   });
// }
