class OtpEntity {
  final bool success;
  final String message;
  final bool isVerified;
  final String token; // 👈 new
  final int userId; // 👈 new

  OtpEntity({
    required this.success,
    required this.message,
    required this.isVerified,
    required this.token,
    required this.userId,
  });
}
