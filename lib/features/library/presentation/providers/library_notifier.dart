import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_favorites_use_case.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_my_creatios_use_case.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/domain/library_quiz.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_notifier_state.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_repository_provider.dart';

class AsyncLibraryNotifier extends AsyncNotifier<LibraryNotifierState> {
  int _currentIndex = 0;
  LibraryFilterParams _queryParams = LibraryFilterParams();

  @override
  Future<LibraryNotifierState> build() async {
    final useCase = FindMyCreatiosUseCase(
      ref.read(libraryRepositoryProvider),
      _queryParams,
    ); //NOTA: modificar el provider de repositorio y los parametros
    final result = await useCase.execute();
    return processResult(result);
  }

  Future<void> loadMyCreations() async {
    _currentIndex = 0;
    _queryParams = _queryParams.copyWith(page: 1);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = FindMyCreatiosUseCase(
        ref.read(libraryRepositoryProvider),
        _queryParams,
      );
      final result = await useCase.execute();
      return processResult(result);
    });
  }

  Future<void> loadFavorites() async {
    _currentIndex = 1;
    _queryParams = _queryParams.copyWith(page: 1);//OJO si hay que inicialziarlo luego de 0
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = FindFavoritesUseCase(
        ref.read(libraryRepositoryProvider),
        _queryParams,
      );
      final result = await useCase.execute();
      return processResult(result);
    });
  }

  Future<LibraryNotifierState> processResult(
    PaginatedResult<LibraryQuiz> result,
  ) async {
    _queryParams = _queryParams.copyWith();
    List<QuizCardUiModel> list = result.items.map((quiz) {
      final imageUrl =
          'https://placehold.co/600x400.png?text=Quiz_Image'; // Modificar luego esto
      switch (_currentIndex) {
        case 0:
          return QuizCardUiModel.forMyCreations(quiz, imageUrl);
        case 1:
          return QuizCardUiModel.forFavorites(quiz, imageUrl);
      }
      return QuizCardUiModel.forMyCreations(quiz, imageUrl);
    }).toList();
    return LibraryNotifierState(
      quizList: list,
      totalCount: result.totalCount,
      totalPages: result.totalPages,
      currentPage: result.currentPage,
      limit: result.limit,
    );
  }

  Future<void> changePage(int newPage) async {
    _queryParams = _queryParams.copyWith(page: newPage);
    state = const AsyncLoading();
    switch (_currentIndex) {
      case 0:
        state = await AsyncValue.guard(() async {
          final useCase = FindMyCreatiosUseCase(
            ref.read(libraryRepositoryProvider),
            _queryParams,
          );
          final result = await useCase.execute();
          return processResult(result);
        });
        break;
      case 1:
        state = await AsyncValue.guard(() async {
          final useCase = FindFavoritesUseCase(
            ref.read(libraryRepositoryProvider),
            _queryParams,
          );
          final result = await useCase.execute();
          return processResult(result);
        });
        break;
    }
  }
}

final asyncLibraryProvider =
    AsyncNotifierProvider<AsyncLibraryNotifier, LibraryNotifierState>(() {
      return AsyncLibraryNotifier();
    });
