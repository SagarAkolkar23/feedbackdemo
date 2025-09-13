class OtpResponseModel {
  final bool success;
  final String message;
  final bool isVerified;
  final String token; // 👈 Add this
  final int userId; // 👈 Add this

  OtpResponseModel({
    required this.success,
    required this.message,
    required this.isVerified,
    required this.token,
    required this.userId,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isVerified: json['isVerified'] ?? false,
      token: json['token'] ?? '', // 👈 extract token
      userId: json['user']?['user_id'] ?? 0, // 👈 extract user_id
    );
  }
}
