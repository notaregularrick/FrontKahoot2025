import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontkahoot2526/features/games/singleplayer/infrastructure/fake_singleplayer_repository.dart';
import 'singleplayer_question_screen.dart';
import 'singleplayer_result_screen.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_notifier.dart';

class SingleplayerOrchestratorScreen extends ConsumerStatefulWidget {
  final String kahootId;
  final String? kahootTitle;

  const SingleplayerOrchestratorScreen({super.key, required this.kahootId, this.kahootTitle});

  @override
  ConsumerState<SingleplayerOrchestratorScreen> createState() => _SingleplayerOrchestratorScreenState();
}

class _SingleplayerOrchestratorScreenState extends ConsumerState<SingleplayerOrchestratorScreen> {
  final FakeSingleplayerRepository _repo = FakeSingleplayerRepository();

  String? _attemptId;
  Map<String, dynamic>? _currentSlide;
  int _currentScore = 0;
  final List<Map<String, dynamic>> _answers = [];
  bool _loading = true;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _startAttempt();
  }

  Future<void> _startAttempt() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final resp = await _repo.createAttempt(widget.kahootId);
    if (!mounted) return;
    setState(() {
      _attemptId = resp['attemptId'] as String?;
      _currentSlide = resp['firstSlide'] as Map<String, dynamic>?;
      _currentScore = 0;
      _loading = false;
    });
  }

  Future<void> _submitAnswer(int answerIndex, int timeElapsedMs) async {
    if (_attemptId == null || _currentSlide == null) return;
    if (!mounted) return;
    setState(() => _loading = true);
    final resp = await _repo.submitAnswer(
      attemptId: _attemptId!,
      slideId: _currentSlide!['slideId'] as String,
      answerIndex: answerIndex,
      timeElapsedMs: timeElapsedMs,
    );

    if (!mounted) return;
    if (resp == null) return;

    // Record this answer for the final breakdown
    final correct = resp['correct'] as bool? ?? false;
    final pointsGained = resp['pointsGained'] as int? ?? 0;
    _answers.add({
      'slideId': _currentSlide!['slideId'],
      'questionText': _currentSlide!['questionText'],
      'answerIndex': answerIndex,
      'correct': correct,
      'pointsGained': pointsGained,
      'timeElapsedMs': timeElapsedMs,
    });

    if (resp['completed'] == true) {
      if (!mounted) return;
      setState(() {
        _currentScore = resp['currentScore'] as int? ?? _currentScore;
        _completed = true;
        _loading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentScore = resp['currentScore'] as int? ?? _currentScore;
      _currentSlide = resp['nextSlide'] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine title: prefer provided title, otherwise try to lookup from library provider
    String title = widget.kahootTitle ?? 'Juego en solitario';
    final asyncLib = ref.watch(asyncLibraryProvider);
    asyncLib.when(
      loading: () {},
      error: (_, __) {},
      data: (notifierState) {
        if (widget.kahootTitle == null) {
          final matches = notifierState.quizList.where((q) => q.id == widget.kahootId);
          if (matches.isNotEmpty) title = matches.first.title;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _completed
                ? SingleplayerResultScreen(
                    score: _currentScore,
                    answers: _answers,
                    onDone: () => context.go('/library'),
                  )
                : SingleplayerQuestionScreen(
                    slide: _currentSlide!,
                    currentScore: _currentScore,
                    onAnswer: (index, timeElapsedMs) => _submitAnswer(index, timeElapsedMs),
                  ),
      ),
    );
  }
}
