import 'package:feedbackdemo/features/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/domain/repository/otpRepository.dart';

class SendOtp {
  final OtpRepository repository;
  SendOtp(this.repository);

  Future<OtpEntity> call(String phone) async {
    return await repository.sendOtp(phone);
  }
}
