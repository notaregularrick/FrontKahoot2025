import 'package:frontkahoot2526/features/library/reports/domain/results.dart';

class ReportNotifierState{
  final List<Results> resultsList;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int limit;

  const ReportNotifierState({
    required this.resultsList,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });
}