import 'package:dio/dio.dart';
import 'package:frontkahoot2526/core/domain/entities/answer.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/core/domain/entities/question.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/domain/library_repository.dart';


class FakeLibraryRepository implements ILibraryRepository{
  //-----PRUEBA
  void pruebaApi() async{
    final Dio dio = Dio();
    Response response = await dio.get('https://51939ed4-750b-431f-86da-d8cfde985ab8.mock.pstmn.io/kahoots/myCreations');
    //print(response.data.toString());
    final Map<String,dynamic> responseBody = response.data;
    final List<dynamic> data = responseBody['data'];
    for (var quiz in data) {
      String id = quiz['id'] as String;
      print(id);
      String title = quiz['title'] as String;
      print(title);
      String description = quiz['description'] as String;
      print(description);
      String themeId = quiz['themeId'] as String;
      print(themeId);
      String category = quiz['category'] as String;
      print(category);
      Map<String,dynamic> author= quiz['author'] as Map<String,dynamic>;
      print(author);
      String authorId = author['id'] as String;
      print(authorId);
      String authorName = author['name'] as String;
      print(authorName);
      String? coverImageId = quiz['coverImageId'] as String?;
      print(coverImageId);
      int playCount = quiz['playCount'] as int;
      print(playCount);
      DateTime createdAt = DateTime.parse(quiz['createdAt'] as String);
      print(createdAt);
      String visibility = quiz['visibility'] as String;
      print(visibility);
      String status = quiz['status'] as String;
      print(status);
      List<Question> questions = []; 
      for(var q in quiz['questions']){
        String questionId = q['id'] as String;
        print(questionId);
        String questionText = q['text'] as String;
        print(questionText);
        String? questionMediaId = q['mediaId'] as String?;
        print(questionMediaId);
        String questionType = q['type'] as String;
        print(questionType);
        int timeLimit = q['timeLimit'] as int;
        print(timeLimit);
        int points = q['points'] as int;
        print(points);
        List<Answer> answers = [];
        for(var a in q['answers']){
          String answerId = a['id'] as String;
          print(answerId);
          String? answerText = a['text'] as String?;
          print(answerText);
          bool isCorrect = a['isCorrect'] as bool;
          print(isCorrect);
          String? answerMediaId = a['mediaId'] as String?;
          print(answerMediaId);
          answers.add(Answer(id: id,
           text: answerText, 
           isCorrect: isCorrect, 
           mediaId: answerMediaId));
        }
        questions.add(
          Question(
            id: questionId,
            text: questionText,
            mediaId: questionMediaId,
            type: questionType,
            timeLimit: timeLimit,
            points: points,
            answers: answers
          )
        );
      }
      Quiz newQuiz =Quiz(id: id, 
        title: title, 
        description: description, 
        visibility: visibility, 
        status: status, 
        category: category, 
        themeId: themeId, 
        authorId: authorId, 
        authorName: authorName, 
        questions: questions, 
        createdAt: createdAt, 
        playCount: playCount, 
        coverImageId: coverImageId);
      print(newQuiz);
      print('---');
    }
  }
  //-----FIN PRUEBA
  //H7.1 Quices creados y borradores
  @override
  Future<PaginatedResult<Quiz>> findMyCreations(LibraryFilterParams params) async{
    await Future.delayed(const Duration(seconds: 1), );
    
    //esto de abajo es el equivalente a response.data
    final Map<String,dynamic> responseBody = {
    //   "data": [
    //     {
    //       "id": "kahoot-uuid-001",
    //       "title": "Historia de Venezuela",
    //       "description": "Un repaso por los próceres",
    //       "themeId": "theme-blue",
    //       "category": "Historia",
    //       "author": { 
    //         "id": "user-uuid-999", 
    //         "name": "Jorge" 
    //       },
    //       "coverImageId": "img-001",
    //       "playCount": 150,
    //       "createdAt": "2025-11-20T10:00:00Z", // ISO 8601 String
    //       "visibility": "public",
    //       "status": "published",
    //       "questions": [] 
    //     },
    //     {
    //       "id": "kahoot-uuid-002",
    //       "title": "Matemáticas Básicas",
    //       "description": "Sumas y restas para niños",
    //       "themeId": "theme-red",
    //       "category": "Matemática",
    //       "author": { 
    //         "id": "user-uuid-999", 
    //         "name": "Jorge" 
    //       },
    //       "coverImageId": null,
    //       "playCount": 0,
    //       "createdAt": "2025-11-21T09:30:00Z",
    //       "visibility": "private",
    //       "status": "draft",
    //       "questions": []
    //     }
    //   ],
    //   "pagination": {
    //     "page": 1,
    //     "limit": 20,
    //     "totalCount": 2,
    //     "totalPages": 1
    //   }
    "data": [
        {
          "id": "kahoot-uuid-001",
          "title": "Historia de Venezuela",
          "description": "Un repaso por los próceres",
          "themeId": "theme-blue",
          "category": "Historia",
          "author": { 
            "id": "user-uuid-999", 
            "name": "Jorge" 
          },
          "coverImageId": "img-001",
          "playCount": 150,
          "createdAt": "2025-11-20T10:00:00Z",
          "visibility": "public",
          "status": "published",
          
          // --- AQUÍ ESTÁ LA ESTRUCTURA QUE PEDISTE ---
          "questions": [
            {
              "id": "q-ven-01",
              "quizId": "kahoot-uuid-001",
              "text": "¿En qué año se firmó el acta de la independencia?",
              "mediaId": null, 
              "type": "quiz", // 'quiz' = Selección simple
              "timeLimit": 30,
              "points": 1000,
              "answers": [
                {
                  "id": "a-ven-01-1",
                  "questionId": "q-ven-01",
                  "text": "1810",
                  "mediaId": null,
                  "isCorrect": false
                },
                {
                  "id": "a-ven-01-2",
                  "questionId": "q-ven-01",
                  "text": "1811",
                  "mediaId": null,
                  "isCorrect": true // Correcta
                },
                {
                  "id": "a-ven-01-3",
                  "questionId": "q-ven-01",
                  "text": "1821",
                  "mediaId": null,
                  "isCorrect": false
                }
              ]
            },
            {
              "id": "q-ven-02",
              "quizId": "kahoot-uuid-001",
              "text": "Simón Bolívar nació en Caracas",
              "mediaId": "img-bolivar",
              "type": "true_false", // 'true_false' = Verdadero/Falso
              "timeLimit": 20,
              "points": 500,
              "answers": [
                {
                  "id": "a-ven-02-1",
                  "questionId": "q-ven-02",
                  "text": "Verdadero",
                  "mediaId": null,
                  "isCorrect": true // Correcta
                },
                {
                  "id": "a-ven-02-2",
                  "questionId": "q-ven-02",
                  "text": "Falso",
                  "mediaId": null,
                  "isCorrect": false
                }
              ]
            }
          ]
          // ---------------------------------------------
        },
        {
          "id": "kahoot-uuid-002",
          "title": "Matemáticas Básicas",
          "description": "Sumas sencillas",
          "themeId": "theme-red",
          "category": "Matemática",
          "author": { 
            "id": "user-uuid-999", 
            "name": "Jorge" 
          },
          "coverImageId": null,
          "playCount": 0,
          "createdAt": "2025-11-21T09:30:00Z",
          "visibility": "private",
          "status": "draft",
          "questions": [] // Ejemplo de lista vacía
        }
      ],
      "pagination": {
        "page": 1,
        "limit": 20,
        "totalCount": 2,
        "totalPages": 1
      }
    };

    final List<dynamic> data = responseBody['data'];
    for (var quiz in data) {
      String id = quiz['id'] as String;
      print(id);
      String title = quiz['title'] as String;
      print(title);
      String description = quiz['description'] as String;
      print(description);
      String themeId = quiz['themeId'] as String;
      print(themeId);
      String category = quiz['category'] as String;
      print(category);
      Map<String,dynamic> author= quiz['author'] as Map<String,dynamic>;
      print(author);
      String authorId = author['id'] as String;
      print(authorId);
      String authorName = author['name'] as String;
      print(authorName);
      String? coverImageId = quiz['coverImageId'] as String?;
      print(coverImageId);
      int playCount = quiz['playCount'] as int;
      print(playCount);
      DateTime createdAt = DateTime.parse(quiz['createdAt'] as String);
      print(createdAt);
      String visibility = quiz['visibility'] as String;
      print(visibility);
      String status = quiz['status'] as String;
      print(status);
      List<Question> questions = []; 
      for(var q in quiz['questions']){
        String questionId = q['id'] as String;
        print(questionId);
        String questionText = q['text'] as String;
        print(questionText);
        String? questionMediaId = q['mediaId'] as String?;
        print(questionMediaId);
        String questionType = q['type'] as String;
        print(questionType);
        int timeLimit = q['timeLimit'] as int;
        print(timeLimit);
        int points = q['points'] as int;
        print(points);
        List<Answer> answers = [];
        for(var a in q['answers']){
          String answerId = a['id'] as String;
          print(answerId);
          String? answerText = a['text'] as String?;
          print(answerText);
          bool isCorrect = a['isCorrect'] as bool;
          print(isCorrect);
          String? answerMediaId = a['mediaId'] as String?;
          print(answerMediaId);
          answers.add(Answer(id: id,
           text: answerText, 
           isCorrect: isCorrect, 
           mediaId: answerMediaId));
        }
        questions.add(
          Question(
            id: questionId,
            text: questionText,
            mediaId: questionMediaId,
            type: questionType,
            timeLimit: timeLimit,
            points: points,
            answers: answers
          )
        );
      }
      Quiz newQuiz =Quiz(id: id, 
        title: title, 
        description: description, 
        visibility: visibility, 
        status: status, 
        category: category, 
        themeId: themeId, 
        authorId: authorId, 
        authorName: authorName, 
        questions: questions, 
        createdAt: createdAt, 
        playCount: playCount, 
        coverImageId: coverImageId);
      print(newQuiz);
      print('---');
    }
    
    return Future.error('error');
  }

  //H7.2 Quices favoritos
  @override
  Future<PaginatedResult<Quiz>> findFavorites(LibraryFilterParams params){
    return Future.error('error');
  }


  //H7.3 Quices en progreso
  @override
  Future<PaginatedResult<Quiz>> findKahootsInProgress(LibraryFilterParams params){
    return Future.error('error');
  }

  //H7.4 Quices completados
  @override
  Future<PaginatedResult<Quiz>> findCompletedKahoots(LibraryFilterParams params){
    return Future.error('error');
  }
}


void main() async {
  // print('--- Iniciando prueba manual ---');
  
  // // 1. Instancia tu repositorio
  // final repository = FakeLibraryRepository();
  
  // // 2. Crea los params (asegúrate de importar la clase o copiarla aquí si da lío)
  // // Como tu LibraryFilterParams tiene valores por defecto, puedes instanciarlo vacío.
  // // Nota: Si te pide importar LibraryFilterParams, asegúrate de que el import sea relativo.
  // final params = LibraryFilterParams(); 

  // try {
  //   // 3. Ejecuta el método
  //   final result = await repository.findMyCreations(params);
    
  // } catch (e) {
  //   print('Error: $e');
  // }
  final repository = FakeLibraryRepository();
  repository.pruebaApi();
}