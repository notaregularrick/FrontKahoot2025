import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/network/dio_provider.dart';
import 'package:frontkahoot2526/features/library/domain/library_repository.dart';
import 'package:frontkahoot2526/features/library/infrastructure/library_repository_impl.dart';

// final libraryRepositoryProvider = Provider<ILibraryRepository>((ref) {
//   return FakeLibraryRepository();
// });

final libraryRepositoryProvider = Provider<ILibraryRepository>((ref) {
  return LibraryRepositoryImpl(ref.watch(dioProvider));
});