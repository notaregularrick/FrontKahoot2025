import 'package:flutter/material.dart';
import '../domain/quiz_template.dart';

/// Lista de plantillas predefinidas disponibles para crear quizzes
final List<QuizTemplate> predefinedTemplates = [
  // ============================================
  // PLANTILLA: HALLOWEEN
  // ============================================
  QuizTemplate(
    id: 'halloween',
    title: '🎃 Halloween Trivia',
    description: '¿Cuánto sabes sobre la noche más terrorífica del año? Pon a prueba tus conocimientos sobre Halloween.',
    category: 'De temporada',
    coverImagePath: 'assets/templates/halloween/cover.png',
    backgroundColor: const Color(0xFF1A1A2E),  
    buttonColor: const Color(0xFFFF6B00),       
    textColor: Colors.white,
    questions: [
      TemplateQuestion(
        text: '¿En qué país se originó Halloween?',
        imagePath: 'assets/templates/halloween/q1.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Irlanda', isCorrect: true),
          TemplateAnswer(text: 'Estados Unidos', isCorrect: false),
          TemplateAnswer(text: 'México', isCorrect: false),
          TemplateAnswer(text: 'Inglaterra', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Qué vegetal se usaba originalmente para hacer linternas antes de las calabazas?',
        imagePath: 'assets/templates/halloween/q2.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Nabo', isCorrect: true),
          TemplateAnswer(text: 'Calabaza', isCorrect: false),
          TemplateAnswer(text: 'Zanahoria', isCorrect: false),
          TemplateAnswer(text: 'Remolacha', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cómo se llama la fobia al Halloween?',
        imagePath: 'assets/templates/halloween/q3.png',
        timeLimit: 25,
        points: 1500,
        answers: [
          TemplateAnswer(text: 'Samhainofobia', isCorrect: true),
          TemplateAnswer(text: 'Aracnofobia', isCorrect: false),
          TemplateAnswer(text: 'Coulrofobia', isCorrect: false),
          TemplateAnswer(text: 'Nictalofobia', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿En qué fecha se celebra Halloween?',
        timeLimit: 15,
        points: 500,
        answers: [
          TemplateAnswer(text: '31 de octubre', isCorrect: true),
          TemplateAnswer(text: '1 de noviembre', isCorrect: false),
          TemplateAnswer(text: '30 de octubre', isCorrect: false),
          TemplateAnswer(text: '2 de noviembre', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Qué significa la palabra "Halloween"?',
        imagePath: 'assets/templates/halloween/q5.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Víspera de Todos los Santos', isCorrect: true),
          TemplateAnswer(text: 'Noche de brujas', isCorrect: false),
          TemplateAnswer(text: 'Día de los muertos', isCorrect: false),
          TemplateAnswer(text: 'Fiesta de disfraces', isCorrect: false),
        ],
      ),
    ],
  ),

  // ============================================
  // PLANTILLA: DISNEY
  // ============================================
  QuizTemplate(
    id: 'disney',
    title: '✨ Disney Magic Quiz',
    description: 'Un viaje mágico por el mundo de Disney. ¿Cuánto sabes sobre las películas más icónicas?',
    category: 'Trivia',
    coverImagePath: 'assets/templates/disney/cover.png',
    backgroundColor: const Color(0xFF1E3A5F),  
    buttonColor: const Color(0xFFFFD700),       
    textColor: Colors.white,
    questions: [
      TemplateQuestion(
        text: '¿Cuál fue la primera película animada de Disney?',
        imagePath: 'assets/templates/disney/q1.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Blancanieves y los Siete Enanitos', isCorrect: true),
          TemplateAnswer(text: 'Pinocho', isCorrect: false),
          TemplateAnswer(text: 'Fantasía', isCorrect: false),
          TemplateAnswer(text: 'Dumbo', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cómo se llama el pez payaso protagonista de "Buscando a Nemo"?',
        imagePath: 'assets/templates/disney/q2.png',
        timeLimit: 15,
        points: 500,
        answers: [
          TemplateAnswer(text: 'Marlin', isCorrect: true),
          TemplateAnswer(text: 'Nemo', isCorrect: false),
          TemplateAnswer(text: 'Dory', isCorrect: false),
          TemplateAnswer(text: 'Gill', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿En qué año se inauguró Disneyland en California?',
        imagePath: 'assets/templates/disney/q3.png',
        timeLimit: 25,
        points: 1500,
        answers: [
          TemplateAnswer(text: '1955', isCorrect: true),
          TemplateAnswer(text: '1960', isCorrect: false),
          TemplateAnswer(text: '1950', isCorrect: false),
          TemplateAnswer(text: '1965', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cuántos enanitos tiene Blancanieves?',
        timeLimit: 15,
        points: 500,
        answers: [
          TemplateAnswer(text: '7', isCorrect: true),
          TemplateAnswer(text: '6', isCorrect: false),
          TemplateAnswer(text: '8', isCorrect: false),
          TemplateAnswer(text: '5', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cómo se llama la villana de "La Sirenita"?',
        imagePath: 'assets/templates/disney/q5.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Úrsula', isCorrect: true),
          TemplateAnswer(text: 'Maléfica', isCorrect: false),
          TemplateAnswer(text: 'Cruella', isCorrect: false),
          TemplateAnswer(text: 'La Reina Malvada', isCorrect: false),
        ],
      ),
    ],
  ),

  // ============================================
  // PLANTILLA: NATURALEZA
  // ============================================
  QuizTemplate(
    id: 'naturaleza',
    title: '🌿 Naturaleza y Animales',
    description: 'Explora el fascinante mundo natural. Descubre datos increíbles sobre animales y ecosistemas.',
    category: 'Estudio',
    coverImagePath: 'assets/templates/naturaleza/cover.png',
    backgroundColor: const Color(0xFF2D5A27), 
    buttonColor: const Color(0xFF8BC34A),       
    textColor: Colors.white,
    questions: [
      TemplateQuestion(
        text: '¿Cuál es el animal más grande del mundo?',
        imagePath: 'assets/templates/naturaleza/q1.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Ballena azul', isCorrect: true),
          TemplateAnswer(text: 'Elefante africano', isCorrect: false),
          TemplateAnswer(text: 'Tiburón ballena', isCorrect: false),
          TemplateAnswer(text: 'Jirafa', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cuántos corazones tiene un pulpo?',
        imagePath: 'assets/templates/naturaleza/q2.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: '3', isCorrect: true),
          TemplateAnswer(text: '1', isCorrect: false),
          TemplateAnswer(text: '2', isCorrect: false),
          TemplateAnswer(text: '4', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cuál es el único mamífero capaz de volar?',
        imagePath: 'assets/templates/naturaleza/q3.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Murciélago', isCorrect: true),
          TemplateAnswer(text: 'Ardilla voladora', isCorrect: false),
          TemplateAnswer(text: 'Colibrí', isCorrect: false),
          TemplateAnswer(text: 'Pez volador', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cuál es el río más largo del mundo?',
        timeLimit: 25,
        points: 1500,
        answers: [
          TemplateAnswer(text: 'Nilo', isCorrect: true),
          TemplateAnswer(text: 'Amazonas', isCorrect: false),
          TemplateAnswer(text: 'Misisipi', isCorrect: false),
          TemplateAnswer(text: 'Yangtsé', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿De qué color es la sangre de los pulpos?',
        imagePath: 'assets/templates/naturaleza/q5.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Azul', isCorrect: true),
          TemplateAnswer(text: 'Roja', isCorrect: false),
          TemplateAnswer(text: 'Verde', isCorrect: false),
          TemplateAnswer(text: 'Transparente', isCorrect: false),
        ],
      ),
    ],
  ),

  // ============================================
  // PLANTILLA: TECNOLOGÍA
  // ============================================
  QuizTemplate(
    id: 'tecnologia',
    title: '💻 Tech Trivia',
    description: '¿Eres un verdadero geek de la tecnología? Demuestra cuánto sabes sobre el mundo tech.',
    category: 'Trivia',
    coverImagePath: 'assets/templates/tecnologia/cover.png',
    backgroundColor: const Color(0xFF0D1117),  
    buttonColor: const Color(0xFF00D4FF),       
    textColor: Colors.white,
    questions: [
      TemplateQuestion(
        text: '¿En qué año se fundó Apple?',
        imagePath: 'assets/templates/tecnologia/q1.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: '1976', isCorrect: true),
          TemplateAnswer(text: '1984', isCorrect: false),
          TemplateAnswer(text: '1990', isCorrect: false),
          TemplateAnswer(text: '1975', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Quién es considerado el padre de la computación?',
        imagePath: 'assets/templates/tecnologia/q2.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Alan Turing', isCorrect: true),
          TemplateAnswer(text: 'Bill Gates', isCorrect: false),
          TemplateAnswer(text: 'Steve Jobs', isCorrect: false),
          TemplateAnswer(text: 'Mark Zuckerberg', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Qué significa "HTML"?',
        timeLimit: 25,
        points: 1500,
        answers: [
          TemplateAnswer(text: 'HyperText Markup Language', isCorrect: true),
          TemplateAnswer(text: 'High Tech Modern Language', isCorrect: false),
          TemplateAnswer(text: 'Home Tool Markup Language', isCorrect: false),
          TemplateAnswer(text: 'HyperText Machine Learning', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿En qué año se lanzó el primer iPhone?',
        imagePath: 'assets/templates/tecnologia/q4.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: '2007', isCorrect: true),
          TemplateAnswer(text: '2005', isCorrect: false),
          TemplateAnswer(text: '2010', isCorrect: false),
          TemplateAnswer(text: '2008', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Qué empresa creó el sistema operativo Android?',
        imagePath: 'assets/templates/tecnologia/q5.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Google', isCorrect: true),
          TemplateAnswer(text: 'Apple', isCorrect: false),
          TemplateAnswer(text: 'Microsoft', isCorrect: false),
          TemplateAnswer(text: 'Samsung', isCorrect: false),
        ],
      ),
    ],
  ),

  // ============================================
  // PLANTILLA: STUDIO GHIBLI
  // ============================================
  QuizTemplate(
    id: 'ghibli',
    title: '🏰 Studio Ghibli',
    description: 'Un viaje mágico por las películas de Hayao Miyazaki y Studio Ghibli. ¿Cuánto sabes?',
    category: 'Trivia',
    coverImagePath: 'assets/templates/ghibli/cover.png',
    backgroundColor: const Color(0xFF87CEEB),  
    buttonColor: const Color(0xFFE8846B),       
    textColor: const Color(0xFF2C3E50),
    questions: [
      TemplateQuestion(
        text: '¿Quién es el fundador de Studio Ghibli?',
        imagePath: 'assets/templates/ghibli/q1.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Hayao Miyazaki', isCorrect: true),
          TemplateAnswer(text: 'Makoto Shinkai', isCorrect: false),
          TemplateAnswer(text: 'Satoshi Kon', isCorrect: false),
          TemplateAnswer(text: 'Mamoru Hosoda', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cómo se llama el gato de "Kiki entregas a domicilio"?',
        imagePath: 'assets/templates/ghibli/q2.png',
        timeLimit: 15,
        points: 500,
        answers: [
          TemplateAnswer(text: 'Chihiro', isCorrect: true),
          TemplateAnswer(text: 'Sophie', isCorrect: false),
          TemplateAnswer(text: 'Jiji', isCorrect: false),
          TemplateAnswer(text: 'Salem', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Porco Rosso es un...?',
        imagePath: 'assets/templates/ghibli/q3.png',
        timeLimit: 25,
        points: 1500,
        answers: [
          TemplateAnswer(text: 'Piloto fascista italiano', isCorrect: false),
          TemplateAnswer(text: 'Cerdo que habla y pilota aviones', isCorrect: true),
          TemplateAnswer(text: 'Pirata del aire', isCorrect: false),
          TemplateAnswer(text: 'Militar de la Primera Guerra Mundial', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Qué película de Ghibli ganó el Oscar a Mejor Película Animada en 2024?',
        imagePath: 'assets/templates/ghibli/q4.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'El niño y la garza', isCorrect: true),
          TemplateAnswer(text: 'La princesa Mononoke', isCorrect: false),
          TemplateAnswer(text: 'El castillo ambulante', isCorrect: false),
          TemplateAnswer(text: 'Ponyo', isCorrect: false),
        ],
      ),
      TemplateQuestion(
        text: '¿Cómo se llama el totoro blanco de "Mi vecino Totoro"?',
        imagePath: 'assets/templates/ghibli/q5.png',
        timeLimit: 20,
        points: 1000,
        answers: [
          TemplateAnswer(text: 'Nekobasu', isCorrect: false),
          TemplateAnswer(text: 'O Totoro', isCorrect: false),
          TemplateAnswer(text: 'Chibi Totoro', isCorrect: true),
          TemplateAnswer(text: 'Chuu Totoro', isCorrect: false),
        ],
      ),
    ],
  ),
];

