import '../../domain/entities/backoffice_notification.dart';
import '../../domain/entities/backoffice_user.dart';

class BackofficeNotificationsState {
  final bool isLoading;
  final List<BackofficeNotificationEntity> notifications;
  final BackofficePaginationEntity? pagination;
  final String? errorMessage;

  const BackofficeNotificationsState({
    this.isLoading = false,
    this.notifications = const [],
    this.pagination,
    this.errorMessage,
  });

  factory BackofficeNotificationsState.initial() => const BackofficeNotificationsState();

  BackofficeNotificationsState copyWith({
    bool? isLoading,
    List<BackofficeNotificationEntity>? notifications,
    BackofficePaginationEntity? pagination,
    String? errorMessage,
  }) {
    return BackofficeNotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
      errorMessage: errorMessage,
    );
  }

  bool get hasMoreData {
    if (pagination == null) return true;
    return pagination!.page < pagination!.totalPages;
  }
}