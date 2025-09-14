import 'package:dio/dio.dart';
import 'package:feedbackdemo/features/otp/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/otp/domain/entity/userEntity.dart';
abstract class OtpRemoteDataSource {
  Future<OtpEntity> requestOtp(String phoneNumber, String token);
  Future<VerifyEntity> verifyOtp(String phoneNumber, String otp);
}

class OtpRemoteDataSourceImpl implements OtpRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  OtpRemoteDataSourceImpl(this.dio, {required this.baseUrl});

  @override
  Future<OtpEntity> requestOtp(String phoneNumber, String token) async {
    final response = await dio.post(
      "$baseUrl/entity/get-otp",
      data: {"phn_number": phoneNumber},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.statusCode == 200) {
      return OtpEntity(
        message: response.data["message"],
        otp: response.data["otp"],
      );
    }
    throw Exception("Failed to get OTP");
  }

  @override
  Future<VerifyEntity> verifyOtp(String phoneNumber, String otp) async {
    final response = await dio.post(
      "$baseUrl/entity/verify-phone",
      data: {"phn_number": phoneNumber, "otp": otp},
    );

    if (response.statusCode == 200 && response.data["success"] == true) {
      final user = response.data["user"];
      return VerifyEntity(
        token: response.data["token"],
        userId: user["user_id"],
        role: user["role"],
        entityId: user["entityId"],
      );
    }
    throw Exception(response.data["message"] ?? "OTP verification failed");
  }
}
