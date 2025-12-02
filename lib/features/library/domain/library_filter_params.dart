class LibraryFilterParams {
  final int page;
  final int limit;
  final String? search; 
  final String status; //draft” | “published” | “all”
  final String visibility; // “public” | “private” | “all” 
  final String orderBy; // “createdAt” | “title” | ”likesCount”
  final String order; // “asc” | “desc”

  const LibraryFilterParams({
    // Valores por defecto
    this.page = 1,              
    this.limit = 20,            
    this.search,                
    this.status = 'all',        
    this.visibility = 'all',    
    this.orderBy = 'createdAt',
    this.order = 'asc',         
  });
  
  LibraryFilterParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? visibility,
    String? orderBy,
    String? order,
  }) {
    return LibraryFilterParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      orderBy: orderBy ?? this.orderBy,
      order: order ?? this.order,
    );
  }
}