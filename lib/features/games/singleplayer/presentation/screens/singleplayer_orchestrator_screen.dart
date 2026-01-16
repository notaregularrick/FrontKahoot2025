import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'singleplayer_question_screen.dart';
import 'singleplayer_result_screen.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_notifier.dart';
import 'package:frontkahoot2526/features/games/singleplayer/presentation/providers/singleplayer_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleplayerOrchestratorScreen extends ConsumerStatefulWidget {
  final String kahootId;
  final String? kahootTitle;
  final String? attemptId;

  const SingleplayerOrchestratorScreen({super.key, required this.kahootId, this.kahootTitle, this.attemptId});

  @override
  ConsumerState<SingleplayerOrchestratorScreen> createState() => _SingleplayerOrchestratorScreenState();
}

class _SingleplayerOrchestratorScreenState extends ConsumerState<SingleplayerOrchestratorScreen> {
  String? _attemptId;
  Map<String, dynamic>? _currentSlide;
  int _currentScore = 0;
  final List<Map<String, dynamic>> _answers = [];
  bool _loading = true;
  bool _completed = false;
  Map<String, dynamic>? _summary;

  static const _prefsKeyPrefix = 'singleplayer_attempt_';

  @override
  void initState() {
    super.initState();
    if (widget.attemptId != null && widget.attemptId!.isNotEmpty) {
      _resumeAttempt(widget.attemptId!);
    } else {
      _startAttempt();
    }
  }

  Future<void> _startAttempt() async {
    final repo = ref.read(singleplayerRepositoryProvider);
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final resp = await repo.createAttempt(widget.kahootId);
      if (!mounted) return;
      final firstSlide = resp['firstSlide'] as Map<String, dynamic>?;
      if (firstSlide == null) {
        setState(() => _loading = false);
        _showError(context, 'El servidor no devolvió la primera pregunta.');
        return;
      }
      setState(() {
        _attemptId = resp['attemptId'] as String?;
        _currentSlide = firstSlide;
        _currentScore = 0;
        _loading = false;
        _completed = false;
        _summary = null;
      });
      if (_attemptId != null && _attemptId!.isNotEmpty) {
        _persistAttemptId(_attemptId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(context, 'No se pudo iniciar el intento: $e');
    }
  }

  Future<void> _resumeAttempt(String attemptId) async {
    final repo = ref.read(singleplayerRepositoryProvider);
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final resp = await repo.getAttempt(attemptId);
      if (!mounted) return;
      if (resp == null) {
        setState(() => _loading = false);
        _showError(context, 'Intento no encontrado');
        return;
      }

      final state = (resp['state'] as String?)?.toUpperCase();
      if (state == 'COMPLETED') {
        final summary = await repo.getSummary(attemptId);
        if (!mounted) return;
        setState(() {
          _attemptId = attemptId;
          _currentScore = summary?['finalScore'] as int? ?? resp['currentScore'] as int? ?? 0;
          _summary = summary;
          _completed = true;
          _loading = false;
        });
        return;
      }

      final nextSlide = resp['nextSlide'] as Map<String, dynamic>?;
      if (nextSlide == null) {
        setState(() => _loading = false);
        _showError(context, 'No hay siguiente pregunta para reanudar.');
        return;
      }

      setState(() {
        _attemptId = resp['attemptId'] as String? ?? attemptId;
        _currentScore = resp['currentScore'] as int? ?? 0;
        _currentSlide = nextSlide;
        _completed = false;
        _summary = null;
        _loading = false;
      });
      if (_attemptId != null && _attemptId!.isNotEmpty) {
        _persistAttemptId(_attemptId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(context, 'No se pudo reanudar el intento: $e');
    }
  }

  Future<void> _submitAnswer(List<int> answerIndexes, int timeElapsedMs) async {
    final repo = ref.read(singleplayerRepositoryProvider);
    final slide = _currentSlide;
    if (_attemptId == null || slide == null) return;
    if (!mounted) return;
    setState(() => _loading = true);
    Map<String, dynamic>? resp;
    try {
      resp = await repo.submitAnswer(
        attemptId: _attemptId!,
        slideId: slide['slideId'] as String,
        answerIndexes: answerIndexes,
        timeElapsedSeconds: (timeElapsedMs / 1000).ceil(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(context, 'No se pudo enviar la respuesta: $e');
      return;
    }

    if (!mounted) return;
    if (resp == null) {
      setState(() => _loading = false);
      _showError(context, 'Respuesta vacía del servidor');
      return;
    }

    // Record this answer for the final breakdown
    final correct = resp['wasCorrect'] as bool? ?? false;
    final pointsGained = resp['pointsEarned'] as int? ?? 0;
    _answers.add({
      'slideId': slide['slideId'],
      'questionText': slide['questionText'],
      'answerIndexes': answerIndexes,
      'correct': correct,
      'pointsGained': pointsGained,
      'timeElapsedMs': timeElapsedMs,
    });

    final attemptState = (resp['attemptState'] as String?)?.toUpperCase();
    final nextSlide = resp['nextSlide'] as Map<String, dynamic>?;

    if (attemptState == 'COMPLETED' || nextSlide == null) {
      final summary = await repo.getSummary(_attemptId!);
      if (!mounted) return;
      final r = resp; // capture to avoid promotion loss warnings
      setState(() {
        _currentScore = (r['updatedScore'] as int?) ?? _currentScore;
        _summary = summary;
        _completed = true;
        _loading = false;
      });
      _clearPersistedAttempt();
      return;
    }

    if (!mounted) return;
    final r = resp; // capture to avoid promotion loss warnings
    setState(() {
      _currentScore = (r['updatedScore'] as int?) ?? _currentScore;
      _currentSlide = nextSlide;
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
                    summary: _summary,
                    answers: _answers,
                    onDone: () => context.go('/library'),
                  )
                : (_currentSlide == null
                    ? const Center(child: Text('No se pudo cargar la pregunta.'))
                    : SingleplayerQuestionScreen(
                        slide: _currentSlide!,
                        currentScore: _currentScore,
                        onAnswer: (indexes, timeElapsedMs) => _submitAnswer(indexes, timeElapsedMs),
                      )),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _persistAttemptId(String attemptId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKeyPrefix${widget.kahootId}', attemptId);
  }

  Future<void> _clearPersistedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsKeyPrefix${widget.kahootId}');
  }
}
