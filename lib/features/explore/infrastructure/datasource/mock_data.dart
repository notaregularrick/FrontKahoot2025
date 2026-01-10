import '../models/quiz_model.dart';

final mockQuiz1 = QuizModel(
  id: 'mock-1',
  title: '🚀 Flutter Masterclass (Mock)',
  description: 'Un quiz exclusivo para demostrar cómo inyectar datos locales sin afectar el backend. Aprende sobre Widgets, Riverpod y Clean Architecture.',
  themeId: 'tech',
  categoryName: 'Technology',
  coverImageUrl: 'https://cdn-images-1.medium.com/max/1200/1*5-aoK8IBmXve5whBQM90GA.png',
  playCount: 9999,
  authorName: 'Gemini AI',
  authorId: 'ai-bot',
  createdAt: DateTime.now(),
  status: 'published',
);

final mockQuiz2 = QuizModel(
  id: 'mock-2',
  title: '🎨 Historia del Arte (Mock)',
  description: 'Descubre los secretos de la Mona Lisa y el Renacimiento en este quiz cultural.',
  themeId: 'art',
  categoryName: 'Arte',
  coverImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/800px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg',
  playCount: 120,
  authorName: 'Leonardo D.',
  authorId: 'leo-1',
  createdAt: DateTime.now().subtract(const Duration(days: 10)),
  status: 'published',
);