import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/domain/entities/paginated_result.dart';
import 'package:frontkahoot2526/core/domain/entities/quiz.dart';
import 'package:frontkahoot2526/features/library/application/use_cases/find_my_creatios_use_case.dart';
import 'package:frontkahoot2526/features/library/domain/library_filter_params.dart';
import 'package:frontkahoot2526/features/library/infrastructure/fake_library_repository_impl.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_notifier_state.dart';
import 'package:frontkahoot2526/features/library/presentation/models/quiz_model.dart';
import 'package:frontkahoot2526/features/library/presentation/providers/library_repository_provider.dart';

class AsyncLibraryNotifier extends AsyncNotifier<LibraryNotifierState> {
  int _currentIndex = 0;
  LibraryFilterParams _queryParams = LibraryFilterParams();

  @override
  Future<LibraryNotifierState> build() async {
    final useCase = FindMyCreatiosUseCase(
      FakeLibraryRepository(),
      LibraryFilterParams(),
    ); //NOTA: modificar el provider de repositorio y los parametros
    final result = await useCase.execute();
    return processResult(result);
  }

  Future<void> loadMyCreations() async {
    _currentIndex = 0;
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1)); //QUITAR LUEGO
    final useCase = FindMyCreatiosUseCase(
      ref.watch(libraryRepositoryProvider),
      _queryParams,
    ); //NOTA: modificar el provider de repositorio y los parametros
    final result = await useCase.execute();
    state = AsyncData(await processResult(result));
  }

  Future<LibraryNotifierState> processResult(
    PaginatedResult<Quiz> result,
  ) async {
    _queryParams = _queryParams.copyWith(page: 1);
    List<QuizCardUiModel> list = result.items.map((quiz) {
      final imageUrl =
          'https://via.placeholder.com/150'; // Modificar luego esto
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

  Future<void> loadFavorites() async {
    _currentIndex = 1;
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1)); //QUITAR LUEGO
    List<QuizCardUiModel> list = [];
    state = AsyncData(
      LibraryNotifierState(
        quizList: list,
        totalCount: 1,
        totalPages: 1,
        currentPage: 10,
        limit: 1,
      ),
    );
  }

  Future<void> changePage(int newPage) async {
    _queryParams = _queryParams.copyWith(page: newPage);
    final result;
    switch (_currentIndex) {
      case 0:
        final useCase = FindMyCreatiosUseCase(
          ref.watch(libraryRepositoryProvider),
          _queryParams,
        );
        result = await useCase.execute();
        state = AsyncData(await processResult(result));
        break;
    }
  }
}

final asyncLibraryProvider =
    AsyncNotifierProvider<AsyncLibraryNotifier, LibraryNotifierState>(() {
      return AsyncLibraryNotifier();
    });
