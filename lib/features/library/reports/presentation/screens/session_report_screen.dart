import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:frontkahoot2526/features/library/reports/domain/player_ranking.dart';
import 'package:frontkahoot2526/features/library/reports/domain/question_analysis.dart';
import 'package:frontkahoot2526/features/library/reports/domain/report.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/providers/report_use_case_providers.dart';

class SessionReportScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const SessionReportScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionReportScreen> createState() =>
      _SessionReportScreenState();
}

class _SessionReportScreenState extends ConsumerState<SessionReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Tab> _tabs = <Tab>[
    Tab(text: 'Ranking'),
    Tab(text: 'Preguntas'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(sessionReportProvider(widget.sessionId));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reporte de sesión', style: TextStyle(fontSize: 25)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          if (error is AppException) {
            if (error.statusCode == 404) {
              return const Center(child: Text("No se encontraron quices"));
            }
            return Center(
              child: Text(
                "Error: ${error.message} (Code: ${error.statusCode}), Details: ${error.error}",
              ),
            );
          }
          return Center(child: Text("Unexpected error: $error"));
        },
        data: (report) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildHeader(report),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryRed,
                  indicatorWeight: 3,
                  labelColor: AppColors.darkBlueText,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  tabs: _tabs,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pestaña 1: Ranking
                    _buildRankingList(report.playerRanking),

                    // Pestaña 2: Preguntas
                    _buildQuestionAnalysisList(report.questionAnalysis),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Report report) {
    final String dateStr =
        "${report.executionDate.day}/${report.executionDate.month}/${report.executionDate.year}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlueText,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                "Jugado el: $dateStr",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(List<PlayerRanking> ranking) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ranking.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final player = ranking[index];
        final isFirstPlace = player.position == 1;

        return Container(
          decoration: BoxDecoration(
            color: isFirstPlace
                ? AppColors.mustardYellow.withValues(alpha: 0.3)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: isFirstPlace
                ? Border.all(color: AppColors.mustardYellow, width: 2)
                : Border.all(color: Colors.transparent),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: isFirstPlace
                  ? AppColors.mustardYellow
                  : Colors.grey[350],
              child: Text(
                "#${player.position}",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: isFirstPlace
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            title: Text(
              player.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text("${player.correctAnswers} aciertos"),
            trailing: Text(
              "${player.score}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBlueText,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionAnalysisList(List<Questionanalysis> analysis) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = analysis[index];
        final double percentageVal = item.correctPercentage.toDouble();
        debugPrint(percentageVal.toString());

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade500),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "P${item.questionIndex + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.questionText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de progreso
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentageVal,
                        minHeight: 10,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForPercentage(percentageVal),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${item.correctPercentage}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorForPercentage(percentageVal),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForPercentage(double value) {
    if (value >= 0.7) return Color(0xFF4CAF50);
    if (value >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
