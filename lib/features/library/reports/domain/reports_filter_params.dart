class ReportsFilterParams {
  final int page;
  final int limit;
  final String order; // “asc” | “desc”

  const ReportsFilterParams({
    // Valores por defecto
    this.page = 1,              
    this.limit = 20,            
    this.order = 'asc',         
  });
  
  ReportsFilterParams copyWith({
    int? page,
    int? limit,
    String? order,
  }) {
    return ReportsFilterParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      order: order ?? this.order,
    );
  }
}