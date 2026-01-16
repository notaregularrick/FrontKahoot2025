import '../../domain/entities/backoffice_user.dart';

class BackofficeState {
  final bool isLoading;
  final List<BackofficeUserEntity> users;
  final BackofficePaginationEntity? pagination;
  final String? errorMessage;

  // Filtros y Ordenamiento activos
  final String searchQuery; 
  final String orderBy;     
  final String order;       

  const BackofficeState({
    this.isLoading = false,
    this.users = const [],
    this.pagination,
    this.errorMessage,
    this.searchQuery = '',
    this.orderBy = 'createdAt',
    this.order = 'asc',
  });

  factory BackofficeState.initial() => const BackofficeState();

  BackofficeState copyWith({
    bool? isLoading,
    List<BackofficeUserEntity>? users,
    BackofficePaginationEntity? pagination,
    String? errorMessage,
    String? searchQuery,
    String? orderBy,
    String? order,
  }) {
    return BackofficeState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      pagination: pagination ?? this.pagination,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      orderBy: orderBy ?? this.orderBy,
      order: order ?? this.order,
    );
  }
  
  
  bool get hasMoreData {
    if (pagination == null) return true;
    return pagination!.page < pagination!.totalPages;
  }
}