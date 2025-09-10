class OtpResponseModel {
  final bool success;
  final String message;
  final String token; // 👈 Add this
  final int userId; // 👈 Add this

  OtpResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.userId,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '', // 👈 extract token
      userId: json['user']?['user_id'] ?? 0, // 👈 extract user_id
    );
  }
}
