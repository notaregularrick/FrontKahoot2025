import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/library/reports/domain/game_type.dart';
import 'package:frontkahoot2526/features/library/reports/presentation/providers/report_use_case_providers.dart';

class PersonalResultsScreen extends ConsumerWidget{
  final String gameId;
  final GameType gameType;
  const PersonalResultsScreen({super.key, required this.gameId, required this.gameType});

   @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(personalResultsProvider((gameId: gameId, gameType: gameType)));
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de mis Resultados")),
      body: results.when(
        data: (data){
          return Center(
            child: Text("Mis resultados para: ${data.title}"),
          );
        },
        error: (err, stack) => Text("Error: $err"),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}