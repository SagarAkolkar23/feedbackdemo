
import 'package:feedbackdemo/features/details/data/repoImpl/entityImpl.dart';
import 'package:feedbackdemo/features/details/data/source/entityRemoteSource.dart';
import 'package:feedbackdemo/features/details/domain/entity/entity.dart';
import 'package:feedbackdemo/features/details/domain/usecases/RegisterEntityUseCase.dart';
import 'package:feedbackdemo/features/details/presentation/controller/entityController.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// ⚠️ Update baseUrl depending on where backend is running
const String baseUrl = "http://localhost:5005"; // for Android emulator

final dioProvider = Provider((ref) {
  final dio = Dio();
  dio.interceptors.add(
    LogInterceptor(responseBody: true),
  ); // logs requests & responses
  return dio;
});

final entityRemoteDataSourceProvider = Provider((ref) {
  return EntityRemoteDataSourceImpl(ref.watch(dioProvider), baseUrl: baseUrl);
});

final entityRepositoryProvider = Provider((ref) {
  return EntityRepositoryImpl(ref.watch(entityRemoteDataSourceProvider));
});

final registerEntityUseCaseProvider = Provider((ref) {
  return RegisterEntityUseCase(ref.watch(entityRepositoryProvider));
});

final entityControllerProvider =
    StateNotifierProvider<EntityController, AsyncValue<Entity?>>((ref) {
      return EntityController(ref.watch(registerEntityUseCaseProvider));
    });

final entityProvider = Provider<Entity?>((ref) {
  final state = ref.watch(entityControllerProvider);
  return state.maybeWhen(data: (entity) => entity, orElse: () => null);
});
