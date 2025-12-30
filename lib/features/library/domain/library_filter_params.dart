class LibraryFilterParams {
  final int page;
  final int limit;
  final String? q; 
  final String status; //draft” | “published” | “all”
  final String visibility; // “public” | “private” | “all” 
  final String orderBy; // “createdAt” | “title” | ”likesCount”
  final String order; // “asc” | “desc”

  const LibraryFilterParams({
    // Valores por defecto
    this.page = 1,              
    this.limit = 20,            
    this.q,                
    this.status = 'all',        
    this.visibility = 'all',    
    this.orderBy = 'createdAt',
    this.order = 'asc',         
  });
  
  LibraryFilterParams copyWith({
    int? page,
    int? limit,
    String? q,
    String? status,
    String? visibility,
    String? orderBy,
    String? order,
  }) {
    return LibraryFilterParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      q: q ?? this.q,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      orderBy: orderBy ?? this.orderBy,
      order: order ?? this.order,
    );
  }
}