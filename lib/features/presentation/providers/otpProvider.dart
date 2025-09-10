import 'package:feedbackdemo/features/data/repositoryImplementation/otpRepositoryImpl.dart';
import 'package:feedbackdemo/features/data/source/otpRemoteSource.dart';
import 'package:feedbackdemo/features/domain/useCases/sendOtp.dart';
import 'package:feedbackdemo/features/domain/useCases/verifyOtp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final httpClientProvider = Provider((ref) => http.Client());

final otpRemoteDataSourceProvider = Provider(
  (ref) => OtpRemoteDataSource(client: ref.watch(httpClientProvider)),
);

final otpRepositoryProvider = Provider(
  (ref) => OtpRepositoryImpl(
    remoteDataSource: ref.watch(otpRemoteDataSourceProvider),
  ),
);

final sendOtpProvider = Provider(
  (ref) => SendOtp(ref.watch(otpRepositoryProvider)),
);

final verifyOtpProvider = Provider(
  (ref) => VerifyOtp(ref.watch(otpRepositoryProvider)),
);
