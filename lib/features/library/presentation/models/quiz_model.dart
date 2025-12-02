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
  final String status;
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
    required this.status,
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
      dateInfo: "${quiz.createdAt.day}/${quiz.createdAt.month}/${quiz.createdAt.year}",
      playCount: "${quiz.playCount} jugadas",
      category: quiz.category,
      status: quiz.status == 'draft' ? 'Borrador' : 'Publicado',
      authorName: null,
      authorId: null,
      visibilityText: quiz.visibility == 'public' ? 'Público' : 'Privado',
      visibilityIcon: quiz.visibility == 'public' ? Icons.public : Icons.lock,
      gameId: null,
      gameType: null,
    );
  }

  factory QuizCardUiModel.forFavorites(LibraryQuiz quiz, String imageUrl) {
    return QuizCardUiModel(
      id: quiz.id,
      title: quiz.title ?? 'Sin título',
      description: quiz.description ?? 'Sin descripción',
      imageUrl: imageUrl,
      themeId: quiz.themeId,
      dateInfo: "${quiz.createdAt.day}/${quiz.createdAt.month}/${quiz.createdAt.year}",
      playCount: "${quiz.playCount} jugadas",
      category: quiz.category,
      status: quiz.status == 'draft' ? 'Borrador' : 'Publicado',
      authorName: quiz.authorName,
      authorId: quiz.authorId,
      visibilityText: null,
      visibilityIcon: null,
      gameId: null,
      gameType: null,
    );
  }

  factory QuizCardUiModel.forInProgress(LibraryQuiz quiz, String imageUrl) {
    return QuizCardUiModel(
      id: quiz.id,
      title: quiz.title ?? 'Sin título',
      description: quiz.description ?? 'Sin descripción',
      imageUrl: imageUrl,
      themeId: quiz.themeId,
      dateInfo: "${quiz.createdAt.day}/${quiz.createdAt.month}/${quiz.createdAt.year}",
      playCount: "${quiz.playCount} jugadas",
      category: quiz.category,
      status: quiz.status == 'draft' ? 'Borrador' : 'Publicado',
      authorName: quiz.authorName,
      authorId: quiz.authorId,
      visibilityText: null,
      visibilityIcon: null,
      gameId: quiz.gameId,
      gameType: quiz.gameType,
    );
  }

}