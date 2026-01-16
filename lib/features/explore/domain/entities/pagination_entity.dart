class PaginationEntity {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;

  const PaginationEntity({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
  });
}