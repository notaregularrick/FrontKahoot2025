import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_my_creatios_use_case.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/infrastructure/fake_library_repository_impl.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_repository_provider.dart';

class AsyncLibraryNotifier extends AsyncNotifier<List<QuizCardUiModel>>{
  
  int _currentIndex = 0;
  LibraryFilterParams queryParams = LibraryFilterParams();

  @override
  Future<List<QuizCardUiModel>> build() async {
    final useCase = FindMyCreatiosUseCase(FakeLibraryRepository(),LibraryFilterParams()); //NOTA: modificar el provider de repositorio y los parametros
    final result = await useCase.execute();
    List<QuizCardUiModel> list = result.items.map((quiz){
      final imageUrl = 'https://via.placeholder.com/150'; // Modificar luego esto
      return QuizCardUiModel.forMyCreations(quiz, imageUrl);
    }).toList();
    return list;
  }

  Future<void> loadMyCreations() async {
    _currentIndex = 0;
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    final useCase = FindMyCreatiosUseCase(ref.watch(libraryRepositoryProvider), queryParams); //NOTA: modificar el provider de repositorio y los parametros
    final result = await useCase.execute();
    List<QuizCardUiModel> list = result.items.map((quiz){
      final imageUrl = 'https://via.placeholder.com/150'; // Modificar luego esto
      return QuizCardUiModel.forMyCreations(quiz, imageUrl);
    }).toList();
    state = AsyncData(list);
  }

  Future<void> loadFavorites() async {
    _currentIndex = 1;
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    List<QuizCardUiModel> list = [];
    state = AsyncData(list);
  }
}

final asyncLibraryProvider = AsyncNotifierProvider<AsyncLibraryNotifier, List<QuizCardUiModel>>(() {
  return AsyncLibraryNotifier();
});