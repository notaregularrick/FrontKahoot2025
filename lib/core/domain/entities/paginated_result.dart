// core/domain/entities/paginated_result.dart
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int limit;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });
}