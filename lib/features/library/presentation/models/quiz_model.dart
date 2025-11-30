import 'package:flutter/material.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';

class QuizCardUiModel {
  final String id;
  final String title;
  final String imageUrl;
  final String questionCount;
  final String dateInfo;
  final String playCount;

  final String? authorName; 
  final String? visibilityText;
  final IconData? visibilityIcon;

  QuizCardUiModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.questionCount,
    required this.dateInfo,
    this.authorName,
    this.visibilityText,
    this.visibilityIcon,
    required this.playCount,
  });

  //Mis quices
  factory QuizCardUiModel.forMyCreations(Quiz quiz, String imageUrl) {
    return QuizCardUiModel(
      id: quiz.id,
      title: quiz.title,
      imageUrl: imageUrl,
      questionCount: "${quiz.questions.length} P",
      dateInfo: "creado el ${quiz.createdAt.day}/${quiz.createdAt.month}/${quiz.createdAt.year}",
      
      authorName: null,
      visibilityText: quiz.visibility == 'public' ? 'Public' : 'Private',
      visibilityIcon: quiz.visibility == 'public' ? Icons.public : Icons.lock,
      playCount: "${quiz.playCount} jugadas"
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