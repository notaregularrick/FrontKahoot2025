import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/library/presentation/screens/pagination_control_widget.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/providers/report_notifier.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/screens/report_options_sheet_widget.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/screens/report_card_widget.dart';

class PlayerReportsScreen extends ConsumerStatefulWidget {
  const PlayerReportsScreen({super.key});

  @override
  ConsumerState<PlayerReportsScreen> createState() =>
      _PlayerReportsScreenState();
}

class _PlayerReportsScreenState extends ConsumerState<PlayerReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPageChanged(int newPage) {
    ref.read(asyncReportProvider.notifier).changePage(newPage);
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(asyncReportProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Mis Resultados"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            //Resultados
            Expanded(
              child: reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  // 1. Lógica para definir el mensaje
                  String errorMessage;

                  if (error is AppException) {
                    if (error.statusCode == 404) {
                      return _buildEmptyState();
                    } else {
                      errorMessage =
                          "Error: ${error.message} (Code: ${error.statusCode}), Details: ${error.error}";
                    }
                  } else {
                    errorMessage = "Unexpected error: $error";
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            // Reintentar carga
                            ref.invalidate(asyncReportProvider);
                          },
                          child: const Text(
                            "Reintentar",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                data: (notifierState) {
                  final results = notifierState.resultsList;

                  if (results.isEmpty) {
                    return _buildEmptyState();
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: results.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return ReportCardWidget(
                              result: results[index],
                              onTap: () => _showReportOptions(results[index]),
                            );
                          },
                        ),
                      ),
                      PaginationControls(
                        currentPage: notifierState.currentPage,
                        totalPages: notifierState.totalPages,
                        onPageChanged: _onPageChanged,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Parece que aún no has jugado ningún quiz",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            "¡Ve a jugar uno y regresa a revisar!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showReportOptions(Results results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ReportOptionsSheet(results: results),
        );
      },
    );
  }

  // void _showReportOptions(Results results) {
  //   switch (results.gameType) {
  //     case GameType.multiplayer:
  //       showModalBottomSheet(
  //         context: context,
  //         isScrollControlled: true,
  //         builder: (context) {
  //           return FractionallySizedBox(
  //             heightFactor: 0.85,
  //             child: ReportOptionsSheet(
  //               results: results,
  //             ),
  //           );
  //         },
  //       );
  //       break;
  //     case GameType.singleplayer:
  //       showModalBottomSheet(
  //         context: context,
  //         isScrollControlled: true,
  //         builder: (context) {
  //           return FractionallySizedBox(
  //             heightFactor: 0.85,
  //             child: Text("detalles"),
  //             //child: QuizOptionsSheet(quiz: quizUiModel, type: contextType),
  //           );
  //         },
  //       );
  //       break;
  //   }

  // showModalBottomSheet(
  //   context: context,
  //   isScrollControlled: true,
  //   builder: (context) {
  //     return FractionallySizedBox(
  //       heightFactor: 0.85,
  //       child: Text("detalles"),
  //       //child: QuizOptionsSheet(quiz: quizUiModel, type: contextType),
  //     );
  //   },
  // );
  //}
}
