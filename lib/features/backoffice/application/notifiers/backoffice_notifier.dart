import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/backoffice_repository.dart';
import '../../domain/entities/backoffice_user.dart'; // Importante para el tipo
import '../state/backoffice_state.dart';

class BackofficeNotifier extends StateNotifier<BackofficeState> {
  final BackofficeRepository repository;
  Timer? _debounce;

  BackofficeNotifier(this.repository) : super(BackofficeState.initial()) {
    loadUsers();
  }

  Future<void> loadUsers({int page = 1, bool isLoadMore = false}) async {
    if (state.isLoading) return;
    if (isLoadMore && !state.hasMoreData) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await repository.getUsers(
        page: page,
        limit: 20,
        name: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        orderBy: state.orderBy,
        order: state.order,
      );

      state = state.copyWith(
        isLoading: false,
        users: isLoadMore 
            ? [...state.users, ...response.data] 
            : response.data,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final updatedUser = await repository.blockUser(userId);
      _updateLocalUser(updatedUser);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final updatedUser = await repository.unblockUser(userId);
      _updateLocalUser(updatedUser);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> giveAdmin(String userId) async {
    try {
      final updatedUser = await repository.giveAdmin(userId);
      _updateLocalUser(updatedUser);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> removeAdmin(String userId) async {
    try {
      final updatedUser = await repository.removeAdmin(userId);
      _updateLocalUser(updatedUser);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await repository.deleteUser(userId);
      
      final updatedList = state.users.where((u) => u.id != userId).toList();
      state = state.copyWith(users: updatedList);
      
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  
  void _updateLocalUser(BackofficeUserEntity updatedUser) {
    final updatedList = state.users.map((user) {
      return user.id == updatedUser.id ? updatedUser : user;
    }).toList();
    
    state = state.copyWith(users: updatedList);
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (state.searchQuery == query) return;
      state = state.copyWith(searchQuery: query);
      loadUsers(page: 1); 
    });
  }

  void onSortChanged(String orderBy) {
    final newOrder = (state.orderBy == orderBy && state.order == 'asc') 
        ? 'desc' 
        : 'asc';
        
    state = state.copyWith(orderBy: orderBy, order: newOrder);
    loadUsers(page: 1);
  }

  Future<void> refresh() async {
    await loadUsers(page: 1);
  }
  
  void loadNextPage() {
    if (state.pagination != null) {
      loadUsers(page: state.pagination!.page + 1, isLoadMore: true);
    }
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}