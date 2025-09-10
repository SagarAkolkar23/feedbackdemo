import 'package:feedbackdemo/features/data/source/otpRemoteSource.dart';
import 'package:feedbackdemo/features/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/domain/repository/otpRepository.dart';

class OtpRepositoryImpl implements OtpRepository {
  final OtpRemoteDataSource remoteDataSource;

  OtpRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OtpEntity> sendOtp(String phone) async {
    final result = await remoteDataSource.sendOtp(phone);
    return OtpEntity(
      success: result.success,
      message: result.message,
      isVerified: false,
      token: '', // No token in sendOtp response
      userId: 0, // No userId yet
    );
  }

  @override
  Future<OtpEntity> verifyOtp(String phone, String otp) async {
    final result = await remoteDataSource.verifyOtp(phone, otp);
    return OtpEntity(
      success: result.success,
      message: result.message,
      isVerified: result.success,
      token: result.token, // 👈 map token
      userId: result.userId, // 👈 map userId
    );
  }
}
