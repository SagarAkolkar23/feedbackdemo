
import 'package:feedbackdemo/features/otp/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/otp/domain/entity/userEntity.dart';

abstract class OtpRepository {
  Future<OtpEntity> requestOtp(String phoneNumber, String token);
  Future<VerifyEntity> verifyOtp(String phoneNumber, String otp);
}
