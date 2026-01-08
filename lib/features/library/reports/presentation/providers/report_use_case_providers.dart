import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/library/reports/application/use_cases/find_my_results_use_case.dart';
import 'package:frontkahoot2526/features/library/reports/application/use_cases/get_general_report_use_case.dart';
import 'package:frontkahoot2526/features/library/reports/application/use_cases/get_personal_result_use_case.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/providers/report_repository_provider.dart';

final findMyResultsUseCaseProvider = Provider<FindMyResultsUseCase>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return FindMyResultsUseCase(repo);
});

final getPersonalResultUseCaseProvider = Provider<GetPersonalResultUseCase>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return GetPersonalResultUseCase(repo);
});

final getGeneralReportUseCaseProvider = Provider<GetGeneralReportUseCase>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return GetGeneralReportUseCase(repo);
});