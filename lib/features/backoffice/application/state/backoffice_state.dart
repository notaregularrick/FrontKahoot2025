import '../../domain/entities/backoffice_user.dart';

class BackofficeState {
  final bool isLoading;
  final List<BackofficeUserEntity> users;
  final BackofficePaginationEntity? pagination;
  final String? errorMessage;

  // Filtros y Ordenamiento activos
  final String searchQuery; // Filtro por nombre ('name')
  final String orderBy;     // 'createdAt', 'name', etc.
  final String order;       // 'asc', 'desc'

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
  
  // Helper para saber si hay más páginas
  bool get hasMoreData {
    if (pagination == null) return true; // Asumimos sí al inicio
    return pagination!.page < pagination!.totalPages;
  }
}