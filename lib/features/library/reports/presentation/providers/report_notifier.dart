import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/reports/domain/reports_filter_params.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/models/report_notifier_state.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/providers/report_use_case_providers.dart';

class AsyncReportNotifier extends AsyncNotifier<ReportNotifierState> {
  ReportsFilterParams _queryParams = ReportsFilterParams();

  @override
  Future<ReportNotifierState> build() async {
    final useCase = ref.read(findMyResultsUseCaseProvider);
    final result = await useCase.execute(_queryParams);
    return processResult(result);
  }

  Future<ReportNotifierState> processResult(
    PaginatedResult<Results> result,
  ) async {
    return ReportNotifierState(
      resultsList: result.items,
      totalCount: result.totalCount,
      totalPages: result.totalPages,
      currentPage: result.currentPage,
      limit: result.limit,
    );
  }

  Future<void> changePage(int newPage) async {
    _queryParams = _queryParams.copyWith(page: newPage);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(findMyResultsUseCaseProvider);
      final result = await useCase.execute(_queryParams);
      return processResult(result);
    });
  }
}

final asyncReportProvider =
    AsyncNotifierProvider<AsyncReportNotifier, ReportNotifierState>(() {
      return AsyncReportNotifier();
    });
