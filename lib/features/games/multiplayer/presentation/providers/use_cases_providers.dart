import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/games/multiplayer/application/change_next_phase_use_case.dart';
import 'package:frontkahoot2526/features/games/multiplayer/application/create_game_use_case.dart';
import 'package:frontkahoot2526/features/games/multiplayer/application/join_game_use_case.dart';
import 'package:frontkahoot2526/features/games/multiplayer/application/listen_game_session_use_case.dart';
import 'package:frontkahoot2526/features/games/multiplayer/application/start_game_use_case.dart';
import 'package:frontkahoot2526/features/games/multiplayer/application/submit_answer_use_case.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_repository_prodiver.dart';

final joinGameUseCaseProvider = Provider<JoinGameUseCase>((ref) {
  final repo = ref.watch(multiplayerGameRepositoryProvider);
  return JoinGameUseCase(repo);
});

final createGameUseCaseProvider = Provider<CreateGameUseCase>((ref) {
  final repo = ref.watch(multiplayerGameRepositoryProvider);
  return CreateGameUseCase(repo);
});

final submitAnswerUseCaseProvider = Provider<SubmitAnswerUseCase>((ref) {
  final repo = ref.watch(multiplayerGameRepositoryProvider);
  return SubmitAnswerUseCase(repo);
});

final listenGameSessionUseCaseProvider = Provider<ListenGameSessionUseCase>((ref) {
  final repo = ref.watch(multiplayerGameRepositoryProvider);
  return ListenGameSessionUseCase(repo);
});

final startGameUseCaseProvider = Provider<StartGameUseCase>((ref) {
  final repo = ref.watch(multiplayerGameRepositoryProvider);
  return StartGameUseCase(repo);
});

final changeNextPhaseUseCaseProvider = Provider<ChangeNextPhaseUseCase>((ref) {
  final repo = ref.watch(multiplayerGameRepositoryProvider);
  return ChangeNextPhaseUseCase(repo);
});