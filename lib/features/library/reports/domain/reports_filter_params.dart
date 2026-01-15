class ReportsFilterParams {
  final int page;
  final int limit;

  const ReportsFilterParams({
    // Valores por defecto
    this.page = 1,              
    this.limit = 20,                    
  });
  
  ReportsFilterParams copyWith({
    int? page,
    int? limit,
  }) {
    return ReportsFilterParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}