import 'package:feedbackdemo/features/tags/data/repoImpl/getTagRepoImpl.dart';
import 'package:feedbackdemo/features/tags/data/source/getTagsSource.dart';
import 'package:feedbackdemo/features/tags/domain/repo/getTagsRepo.dart';
import 'package:feedbackdemo/features/tags/domain/useCase.dart/getTagsUseCase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) => Dio());

// Remote source provider
final tagRemoteSourceProvider = Provider<GetTagRemoteDataSource>(
  (ref) => GetTagRemoteDataSourceImpl(
    ref.watch(dioProvider),
    baseUrl: "http://localhost:5005", // replace with your backend
  ),
);

// Repository provider
final tagRepositoryProvider = Provider<GetTagsRepository>(
  (ref) => GetTagRepositoryImpl(ref.watch(tagRemoteSourceProvider)),
);

// UseCase provider
final getTagsUseCaseProvider = Provider<GetTagsUseCase>(
  (ref) => GetTagsUseCase(ref.watch(tagRepositoryProvider)),
);

final allTagsProvider = FutureProvider.family<List<String>, String>((
  ref,
  token,
) async {
  return ref.watch(getTagsUseCaseProvider).call(token: token);
});


