import 'package:feedbackdemo/features/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/domain/repository/otpRepository.dart';

class VerifyOtp {
  final OtpRepository repository;
  VerifyOtp(this.repository);

  Future<OtpEntity> call(String phone, String otp) async {
    return await repository.verifyOtp(phone, otp);
  }
}
