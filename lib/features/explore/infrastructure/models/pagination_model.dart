import '../../domain/entities/pagination_entity.dart';

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required super.page,
    required super.limit,
    required super.totalCount,
    required super.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: _parseInt(json['page']) ?? 1,
      limit: _parseInt(json['limit']) ?? 20,
      totalCount: _parseInt(json['totalCount']) ?? 0,
      totalPages: _parseInt(json['totalPages']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}