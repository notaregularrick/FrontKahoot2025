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
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}