

import 'package:feedbackdemo/features/otp/data/source/otpSource.dart';
import 'package:feedbackdemo/features/otp/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/otp/domain/entity/userEntity.dart';
import 'package:feedbackdemo/features/otp/domain/repo/otpRepo.dart';

class OtpRepositoryImpl implements OtpRepository {
  final OtpRemoteDataSource remote;

  OtpRepositoryImpl(this.remote);

  @override
  Future<OtpEntity> requestOtp(String phoneNumber, String token) {
    return remote.requestOtp(phoneNumber, token);
  }

  @override
  Future<VerifyEntity> verifyOtp(String phoneNumber, String otp) {
    return remote.verifyOtp(phoneNumber, otp);
  }
}
