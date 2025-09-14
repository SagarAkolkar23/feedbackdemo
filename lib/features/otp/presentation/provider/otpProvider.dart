import 'package:dio/dio.dart';
import 'package:feedbackdemo/features/otp/data/repoImpl/otpRepoImpl.dart';
import 'package:feedbackdemo/features/otp/data/source/otpSource.dart';
import 'package:feedbackdemo/features/otp/domain/useCase/getOtp.dart';
import 'package:feedbackdemo/features/otp/domain/useCase/verifyOtp.dart';
import 'package:feedbackdemo/features/otp/presentation/controller/otpController.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


const baseUrl = "http://localhost:5005";

final dioProvider = Provider((ref) => Dio());

final otpRemoteSourceProvider = Provider(
  (ref) => OtpRemoteDataSourceImpl(ref.watch(dioProvider), baseUrl: baseUrl),
);

final otpRepoProvider = Provider(
  (ref) => OtpRepositoryImpl(ref.watch(otpRemoteSourceProvider)),
);

final requestOtpUseCaseProvider = Provider(
  (ref) => RequestOtpUseCase(ref.watch(otpRepoProvider)),
);

final verifyOtpUseCaseProvider = Provider(
  (ref) => VerifyOtpUseCase(ref.watch(otpRepoProvider)),
);

final otpControllerProvider =
    StateNotifierProvider<OtpController, AsyncValue<void>>(
      (ref) => OtpController(
        ref.watch(requestOtpUseCaseProvider),
        ref.watch(verifyOtpUseCaseProvider),
      ),
    );


