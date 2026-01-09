import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/providers/report_use_case_providers.dart';

class SessionReportScreen extends ConsumerWidget{
  final String sessionId;
  const SessionReportScreen({super.key, required this.sessionId});

   @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(sessionReportProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: Text("Detalle del Reporte")),
      body: report.when(
        data: (data){
          return Center(
            child: Text("Reporte para la sesión: ${data.title}"),
          );
        }, // Aquí pintas tu UI estática
        error: (err, stack) => Text("Error: $err"),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}