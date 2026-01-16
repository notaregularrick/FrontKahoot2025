import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/backoffice_repository.dart';
import '../state/backoffice_notifications_state.dart';

class BackofficeNotificationsNotifier extends StateNotifier<BackofficeNotificationsState> {
  final BackofficeRepository repository;

  BackofficeNotificationsNotifier(this.repository) : super(BackofficeNotificationsState.initial()) {
    loadNotifications();
  }

  Future<void> loadNotifications({int page = 1, bool isLoadMore = false}) async {
    if (state.isLoading) return;
    if (isLoadMore && !state.hasMoreData) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await repository.getMassNotifications(
        page: page,
        limit: 20,
        orderBy: 'createdAt',
        order: 'desc',
      );

      state = state.copyWith(
        isLoading: false,
        notifications: isLoadMore 
            ? [...state.notifications, ...response.data] 
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

  Future<void> sendNotification({
    required String title,
    required String message,
    required bool toAdmins,
    required bool toRegularUsers,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await repository.sendMassNotification(
        title: title,
        message: message,
        toAdmins: toAdmins,
        toRegularUsers: toRegularUsers,
      );
      
      await loadNotifications(page: 1); 

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadNotifications(page: 1);
  }
  
  void loadNextPage() {
    if (state.pagination != null) {
      loadNotifications(page: state.pagination!.page + 1, isLoadMore: true);
    }
  }
}