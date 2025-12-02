import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_completed_quizzes.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_favorites_use_case.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_my_creatios_use_case.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_quizzes_in_progress.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/remove_favorite_quiz_use_case.dart';
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
    _queryParams = LibraryFilterParams();
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
    _queryParams = LibraryFilterParams();
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

  Future<void> loadQuizzesInProgress() async {
    _currentIndex = 2;
    _queryParams = LibraryFilterParams();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = FindQuizzesInProgressUseCase(
        ref.read(libraryRepositoryProvider),
        _queryParams,
      );
      final result = await useCase.execute();
      return processResult(result);
    });
  }

  Future<void> loadCompletedQuizzes() async {
    _currentIndex = 3;
    _queryParams = LibraryFilterParams();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = FindCompletedQuizzesUseCase(
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
        case 2:
          return QuizCardUiModel.forInProgress(quiz, imageUrl);
        case 3:
          return QuizCardUiModel.forCompleted(quiz, imageUrl);
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
      case 2:
        state = await AsyncValue.guard(() async {
          final useCase = FindQuizzesInProgressUseCase(
            ref.read(libraryRepositoryProvider),
            _queryParams,
          );
          final result = await useCase.execute();
          return processResult(result);
        });
      case 3:
        state = await AsyncValue.guard(() async {
          final useCase = FindCompletedQuizzesUseCase(
            ref.read(libraryRepositoryProvider),
            _queryParams,
          );
          final result = await useCase.execute();
          return processResult(result);
        });
        break;
    }
  }

  Future<void> reloadPage() async{
    await changePage(_queryParams.page);
  }

  Future<void> searchQuizzes(String query) async{
    _queryParams = _queryParams.copyWith(search: query);
    state = const AsyncLoading();
    await changePage(1);
  }

  Future<void> removeFavorite(String quizId) async {
    final oldState = state.value; 
    if (oldState == null) return;
    state = await AsyncValue.guard(() async {
      final useCase = RemoveFavoriteQuizUseCase(
        ref.read(libraryRepositoryProvider),
      );
      await useCase.execute(quizId);
      List<QuizCardUiModel> newList = oldState.quizList
          .where((quiz) => quiz.id != quizId)
          .toList();
      return LibraryNotifierState(
        quizList: newList,
        totalCount: oldState.totalCount - 1,
        totalPages: oldState.totalPages,
        currentPage: oldState.currentPage,
        limit: oldState.limit,
      );
    });
    // if (state.hasError) {
    //    // NOTA:Esto mantiene el error pero recupera la data vieja (para snackbar puede servir)
    //    state = AsyncValue<LibraryNotifierState>.error(state.error!, state.stackTrace!).copyWithPrevious(AsyncData(oldState));
    // }
  }
}

final asyncLibraryProvider =
    AsyncNotifierProvider<AsyncLibraryNotifier, LibraryNotifierState>(() {
      return AsyncLibraryNotifier();
    });
