import 'package:flutter/material.dart';
import 'package:frontkahoot2526/features/library/domain/library_quiz.dart';

class QuizCardUiModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String themeId;
  final String dateInfo;
  final String playCount;
  final String category;
  final String? authorName; 
  final String? authorId;
  final String? visibilityText;
  final IconData? visibilityIcon;
  final String? gameId;
  final String? gameType;

  QuizCardUiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.themeId,
    required this.dateInfo,
    required this.playCount,
    required this.category,
    this.authorName,
    this.authorId,
    this.visibilityText,
    this.visibilityIcon,
    this.gameId,
    this.gameType,
  });

  //Mis quices
  factory QuizCardUiModel.forMyCreations(LibraryQuiz quiz, String imageUrl) {
    return QuizCardUiModel(
      id: quiz.id,
      title: quiz.title ?? 'Sin título',
      description: quiz.description ?? 'Sin descripción',
      imageUrl: imageUrl,
      themeId: quiz.themeId,
      dateInfo: "Creado el ${quiz.createdAt.day}/${quiz.createdAt.month}/${quiz.createdAt.year}",
      playCount: "${quiz.playCount} jugadas",
      category: quiz.category,
      authorName: null,
      authorId: null,
      visibilityText: quiz.visibility == 'public' ? 'Público' : 'Privado',
      visibilityIcon: quiz.visibility == 'public' ? Icons.public : Icons.lock,
      gameId: null,
      gameType: null,
    );
  }

  //Favoritos
  // factory QuizCardUiModel.forFavorites(Quiz quiz, String imageUrl) {
  //   return QuizCardUiModel(
  //     id: quiz.id,
  //     title: quiz.title,
  //     imageUrl: imageUrl,
  //     questionCount: "${quiz.questions.length} Preguntas",
  //     dateInfo: "creado el ${quiz.createdAt.day}/${quiz.createdAt.month}/${quiz.createdAt.year}",
      
  //     authorName: quiz.authorName,
  //     visibilityText: null,
  //     visibilityIcon: null,
  //   );
  // }
}