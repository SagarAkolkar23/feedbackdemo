import 'dart:async';
import 'package:feedbackdemo/features/domain/entity/otpEntity.dart';
import 'package:feedbackdemo/features/presentation/providers/otpProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OTP Controller with StateNotifier + AsyncValue + Timer
class OtpController extends StateNotifier<AsyncValue<OtpEntity?>> {
  OtpController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  bool showOtpField = false;
  int _seconds = 120;
  Timer? _timer;
  final TextEditingController otpController = TextEditingController();

  int get secondsRemaining => _seconds;

  String get formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// Request OTP from backend (does NOT start timer automatically)
  Future<void> sendOtp(String phone) async {
    state = const AsyncValue.loading();
    try {
      final result = await ref.read(sendOtpProvider).call(phone);
      state = AsyncValue.data(result);
      // ✅ Timer will be started manually by UI
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Verify OTP with backend
  Future<void> verifyOtp(String phone) async {
    if (otpController.text.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final result = await ref
          .read(verifyOtpProvider)
          .call(phone, otpController.text);
      state = AsyncValue.data(result);

      // stop timer once verified
      stopOtpTimer();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Starts a 2-min timer (called manually when user clicks "Get OTP")
  void startOtpTimer() {
    showOtpField = true;
    _seconds = 120;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 0) {
        timer.cancel();
        showOtpField = false;
      } else {
        _seconds--;
      }
      state = _copyWithSame(); // refresh UI
    });
  }

  void stopOtpTimer() {
    _timer?.cancel();
    showOtpField = false;
    state = _copyWithSame();
  }

  AsyncValue<OtpEntity?> _copyWithSame() {
    return state.when(
      data: (value) => AsyncValue.data(value),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }
}

final otpControllerProvider =
    StateNotifierProvider<OtpController, AsyncValue<OtpEntity?>>(
      (ref) => OtpController(ref),
    );
