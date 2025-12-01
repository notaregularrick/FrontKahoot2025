class UserEntity{
  final String id;
  final String name;
  final String email;
  final String userType;
  final DateTime createdAt;

  UserEntity({required this.id,
              required this.name,
              required this.email,
              required this.userType,
              required this.createdAt,
              });
}