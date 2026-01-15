import 'package:frontkahoot2526/features/games/multiplayer/domain/question_type.dart';

class CurrentQuestion {
  final String questionId;
  final int questionIndex;
  final QuestionType type;
  final int timeLimitSeconds;
  final String questionText;
  final String questionImageUrl;
  final int pointsValue;
  final List<QuestionAnswers> options;
  final int? numberOfSubmissions;

  const CurrentQuestion({
    required this.questionId,
    required this.questionIndex,
    required this.type,
    required this.questionText,
    required this.questionImageUrl,
    required this.timeLimitSeconds,
    required this.pointsValue,
    required this.options,
    this.numberOfSubmissions,
  });

  CurrentQuestion copyWith({
    String? questionId,
    int? questionIndex,
    QuestionType? type,
    int? timeLimitSeconds,
    String? questionText,
    String? questionImageUrl,
    int? pointsValue,
    List<QuestionAnswers>? options,
    int? numberOfSubmissions,
  }) {
    return CurrentQuestion(
      questionId: questionId ?? this.questionId,
      questionIndex: questionIndex ?? this.questionIndex,
      type: type ?? this.type,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      questionText: questionText ?? this.questionText,
      questionImageUrl: questionImageUrl ?? this.questionImageUrl,
      pointsValue: pointsValue ?? this.pointsValue,
      options: options ?? this.options,
      numberOfSubmissions: numberOfSubmissions ?? this.numberOfSubmissions,
    );
  }

  factory CurrentQuestion.fromJson(Map<String, dynamic> json) {
    String qId = json['id'] as String? ?? '';
    int qIndex = (json['position'] as num?)?.toInt() ?? 0;
    QuestionType qType = _mapStringToQuestionType(json['slideType'] as String?);
    int tLimit = (json['timeLimitSeconds'] as num?)?.toInt() ?? 20;
    String qText = json['questionText'] as String? ?? '';
    String qImageUrl = json['slideImageURL'] as String? ?? '';
    int points = (json['pointsValue'] as num?)?.toInt() ?? 0;

    List<QuestionAnswers> qOptions =
        (json['options'] as List?)
            ?.map((e) => QuestionAnswers.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CurrentQuestion(
      questionId: qId,
      questionIndex: qIndex,
      type: qType,
      timeLimitSeconds: tLimit,
      questionText: qText,
      questionImageUrl: qImageUrl,
      pointsValue: points,
      options: qOptions,
    );
  }
  static QuestionType _mapStringToQuestionType(String? typeStr) {
    switch (typeStr?.toUpperCase()) {
      case 'SINGLE':
        return QuestionType.single;
      case 'MULTI':
      case 'MULTIPLE':
        return QuestionType.multipleChoice;
      case 'TRUE_FALSE':
        return QuestionType.trueFalse;
      default:
        return QuestionType.single; // Valor por defecto para evitar errores
    }
  }

  //POr ahora no sirve
  // String getAnswerTextByIndex(int index) {
  //   if (index < 0 || index >= options.length) {
  //     return '';
  //   } else {
  //     return options
  //         .firstWhere((option) => option.answerIndex == index)
  //         .answerText ??;
  //   }
  // }

  void logDebugInfo() {
    print('\n===== 🔍 DETALLES DE LA PREGUNTA =====');
    print('🆔 ID: $questionId');
    print('📍 Índice: $questionIndex');
    print('🗂️ Tipo: $type');
    print('📝 Texto: "$questionText"');
    print('⏱️ Tiempo Límite: ${timeLimitSeconds}s');
    print('🏆 Valor Puntos: $pointsValue');
    print(
      '🖼️ URL Imagen: ${questionImageUrl.isEmpty ? "Ninguna" : questionImageUrl}',
    );

    print('🔠 Opciones (${options.length}):');
    if (options.isEmpty) {
      print('   ⚠️ No hay opciones disponibles');
    } else {
      for (var opt in options) {
        print('   🔹 [${opt.answerIndex}] ${opt.toString()}');
      }
    }
    print('========================================\n');
  }
}

class QuestionAnswers {
  final String answerIndex;
  final String? answerText;
  final String? answerImageUrl;

  const QuestionAnswers({
    required this.answerIndex,
    this.answerText,
    this.answerImageUrl,
  });

  factory QuestionAnswers.fromJson(Map<String, dynamic> json) {
    String aIndex = json['index'] as String? ?? '0';
    String? aText = json['text'] as String?;
    String? aImageUrl = json['mediaURL'] as String?;

    return QuestionAnswers(
      answerIndex: aIndex,
      answerText: aText,
      answerImageUrl: aImageUrl,
    );
  }
}

void main(List<String> args) {
  final mockdata = {
    "state": "question",
    "currentSlideData": {
      "id": "a187a224-95a9-47ca-8d68-509dd13d7c96",
      "position": 3,
      "slideType": "SINGLE",
      "timeLimitSeconds": 30,
      "questionText":
          "¿Qué patrón estructural se utiliza para permitir que interfaces incompatibles trabajen juntas?",
      "slideImageURL":
          "https://res.cloudinary.com/dcmbpjmqs/image/upload/v1/quizzy_assets/themes/tema-5-516da7?_a=BAMAMiZW0",
      "pointsValue": 1000,
      "options": [
        {"index": "0", "text": "Adapter"},
        {"index": "1", "text": "Bridge"},
        {"index": "2", "text": "Proxy"},
        {"index": "3", "text": "Decorator"},
      ],
    },
  };
  CurrentQuestion question = CurrentQuestion.fromJson(
    mockdata['currentSlideData'] as Map<String, dynamic>,
  );
  question.logDebugInfo();
}
