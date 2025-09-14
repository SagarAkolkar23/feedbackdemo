
import 'package:feedbackdemo/features/otp/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/otp/domain/entity/userEntity.dart';
import 'package:feedbackdemo/features/otp/domain/useCase/getOtp.dart';
import 'package:feedbackdemo/features/otp/domain/useCase/verifyOtp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpController extends StateNotifier<AsyncValue<void>> {
  final RequestOtpUseCase requestOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  String? _phone; // store the phone internally

  OtpController(this.requestOtpUseCase, this.verifyOtpUseCase)
    : super(const AsyncValue.data(null));

  /// Request OTP and store phone internally
  Future<OtpEntity> requestOtp(String phone, String token) async {
    _phone = phone; // store the phone
    print(
      "📲 [OtpController] Starting requestOtp for phone: $phone, token: $token",
    );
    state = const AsyncValue.loading();

    try {
      final res = await requestOtpUseCase(phone, token);
      print("✅ [OtpController] OTP request successful for phone: $phone");
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      print("❌ [OtpController] requestOtp failed: $e");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Verify OTP using stored phone
  Future<VerifyEntity> verifyOtp(String otp) async {
    if (_phone == null) throw Exception("Phone number not set!");
    print(
      "📲 [OtpController] Starting verifyOtp for phone: $_phone, otp: $otp",
    );
    state = const AsyncValue.loading();

    try {
      final res = await verifyOtpUseCase(_phone!, otp);
      print("✅ [OtpController] OTP verification successful for phone: $_phone");
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      print("❌ [OtpController] verifyOtp failed: $e");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Optional: expose phone if needed elsewhere
  String? get phone => _phone;
}
