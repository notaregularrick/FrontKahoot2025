import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/network/dio_provider.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_repository.dart';
import 'package:frontkahoot2526/features/library/reports/infrastructure/report_repository_impl.dart';

// final reportRepositoryProvider = Provider<IReportsRepository>((ref) {
//   return FakeReportRepositoryImpl();
//   //return LibraryRepositoryImpl(ref.watch(dioProvider));
// });

final reportRepositoryProvider = Provider<IReportsRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(dioProvider));
});