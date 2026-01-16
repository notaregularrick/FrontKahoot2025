import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
import 'package:frontkahoot2526/features/library/reports/domain/results.dart';
import 'package:go_router/go_router.dart';

class ReportOptionsSheet extends ConsumerWidget {
  final Results results;

  const ReportOptionsSheet({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 2. Título del Quiz
            Text(
              results.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30),

            if (results.gameType == GameType.multiplayerHost) ...[
              createSessionReportBtn(context),
            ],
            if (results.gameType != GameType.multiplayerHost)...[
              createSessionPersonalResultsBtn(context),
            ]
            
          ],
        ),
      ),
    );
  }

  Widget createSessionReportBtn(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bar_chart),
      title: Text(
        "Ver reporte de la sesión",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      onTap: () {
        Navigator.pop(context);
        context.push('/reports/sessionReport/${results.gameId}');
      },
    );
  }

  Widget createSessionPersonalResultsBtn(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bar_chart),
      title: Text(
        "Ver mis resultados",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      onTap: () {
        Navigator.pop(context);
        final typeName = results.gameType == GameType.multiplayerPlayer
            ? 'multiplayer'
            : 'singleplayer';
        context.push('/reports/personalResults/${results.gameId}/$typeName');
      },
    );
  }
}
