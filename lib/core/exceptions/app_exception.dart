class AppException implements Exception {
  final String message;      
  final int? statusCode;     
  final String? error;       

  AppException({
    required this.message,
    this.statusCode,
    this.error,
  });
}