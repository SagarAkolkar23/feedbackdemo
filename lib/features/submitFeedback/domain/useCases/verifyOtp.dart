import 'package:feedbackdemo/features/submitFeedback/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/submitFeedback/domain/repository/otpRepository.dart';

class VerifyOtp {
  final OtpRepository repository;
  VerifyOtp(this.repository);

  Future<OtpEntity> call(String phone, String otp) async {
    return await repository.verifyOtp(phone, otp);
  }
}
