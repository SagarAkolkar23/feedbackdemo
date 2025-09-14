class VerifyEntity {
  final String token;
  final int userId;
  final String role;
  final int entityId;

  const VerifyEntity({
    required this.token,
    required this.userId,
    required this.role,
    required this.entityId,
  });
}
