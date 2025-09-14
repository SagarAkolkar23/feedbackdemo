
import 'package:feedbackdemo/features/otp/domain/entity/userEntity.dart';
import 'package:feedbackdemo/features/otp/domain/repo/otpRepo.dart';


class VerifyOtpUseCase {
  final OtpRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<VerifyEntity> call(String phoneNumber, String otp) {
    return repository.verifyOtp(phoneNumber, otp);
  }
}
