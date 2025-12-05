import 'dart:async';
import 'dart:math';

class SlideOption {
  final int index;
  final String? text;
  final String? mediaUrl;

  SlideOption({required this.index, this.text, this.mediaUrl});
}

class Slide {
  final String id;
  final String questionType;
  final String questionText;
  final int timeLimitSeconds;
  final String? mediaUrl;
  final List<SlideOption> options;

  Slide({
    required this.id,
    required this.questionType,
    required this.questionText,
    required this.timeLimitSeconds,
    this.mediaUrl,
    required this.options,
  });
}

class AttemptState {
  final String attemptId;
  final String kahootId;
  int currentIndex;
  int currentScore;
  final List<Slide> slides;
  bool completed;

  AttemptState({
    required this.attemptId,
    required this.kahootId,
    required this.slides,
  })  : currentIndex = 0,
        currentScore = 0,
        completed = false;
}

class FakeSingleplayerRepository {
  final Map<String, AttemptState> _attempts = {};
  final Random _rnd = Random();

  Future<Map<String, dynamic>> createAttempt(String kahootId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final attemptId = 'att_${DateTime.now().millisecondsSinceEpoch}_${_rnd.nextInt(9999)}';
    // Generate a small set of slides for demo
    final slides = List.generate(5, (i) {
      return Slide(
        id: 's_${i}',
        questionType: 'single_choice',
        questionText: 'Pregunta ${i + 1}',
        timeLimitSeconds: 20,
        mediaUrl: null,
        options: List.generate(4, (j) => SlideOption(index: j, text: 'Opción ${j + 1}')),
      );
    });

    final attempt = AttemptState(attemptId: attemptId, kahootId: kahootId, slides: slides);
    _attempts[attemptId] = attempt;

    return {
      'attemptId': attemptId,
      'firstSlide': _slideToMap(attempt.slides.first),
    };
  }

  Future<Map<String, dynamic>?> getAttempt(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final attempt = _attempts[attemptId];
    if (attempt == null) return null;

    if (attempt.completed) {
      return {
        'attemptId': attempt.attemptId,
        'state': 'COMPLETED',
        'currentScore': attempt.currentScore,
      };
    }

    final nextSlide = attempt.slides[attempt.currentIndex];
    return {
      'attemptId': attempt.attemptId,
      'state': 'IN_PROGRESS',
      'currentScore': attempt.currentScore,
      'nextSlide': _slideToMap(nextSlide),
    };
  }

  Future<Map<String, dynamic>?> submitAnswer({
    required String attemptId,
    required String slideId,
    required int answerIndex,
    required int timeElapsedMs,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final attempt = _attempts[attemptId];
    if (attempt == null) return null;

    if (attempt.completed) {
      return {'completed': true};
    }

    // For demo: option index 0 is correct
    final correct = answerIndex == 0;
    final points = correct ? 100 : 0;
    attempt.currentScore += points;

    // advance
    attempt.currentIndex += 1;
    if (attempt.currentIndex >= attempt.slides.length) {
      attempt.completed = true;
      return {
        'correct': correct,
        'pointsGained': points,
        'currentScore': attempt.currentScore,
        'completed': true,
      };
    }

    final next = attempt.slides[attempt.currentIndex];
    return {
      'correct': correct,
      'pointsGained': points,
      'currentScore': attempt.currentScore,
      'completed': false,
      'nextSlide': _slideToMap(next),
    };
  }

  Map<String, dynamic> _slideToMap(Slide s) {
    return {
      'slideId': s.id,
      'questionType': s.questionType,
      'questionText': s.questionText,
      'timeLimitSeconds': s.timeLimitSeconds,
      'mediaUrl': s.mediaUrl,
      'options': s.options.map((o) => {'index': o.index, 'text': o.text, 'mediaUrl': o.mediaUrl}).toList(),
    };
  }
}
