

import 'package:feedbackdemo/features/otp/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/otp/domain/repo/otpRepo.dart';

class RequestOtpUseCase {
  final OtpRepository repository;
  RequestOtpUseCase(this.repository);

  Future<OtpEntity> call(String phoneNumber, String token) {
    return repository.requestOtp(phoneNumber, token);
  }
}
