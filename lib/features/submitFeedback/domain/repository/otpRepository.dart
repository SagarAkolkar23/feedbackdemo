import 'package:feedbackdemo/features/submitFeedback/domain/entity/otpEntity.dart';


abstract class OtpRepository {
  Future<OtpEntity> sendOtp(String phone);
  Future<OtpEntity> verifyOtp(String phone, String otp);
}
