
import 'package:feedbackdemo/features/tags/data/repoImpl/tagsRepoImplementation.dart';
import 'package:feedbackdemo/features/tags/data/source/tagsRemoteSource.dart';
import 'package:feedbackdemo/features/tags/domain/useCase.dart/tagUseCase.dart';
import 'package:feedbackdemo/features/tags/presentation/controller/tagsController.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

const baseUrl = "http://localhost:5005";

final dioProvider = Provider((ref) => Dio());

final tagRemoteSourceProvider = Provider<TagRemoteDataSource>(
  (ref) => TagRemoteDataSourceImpl(ref.watch(dioProvider), baseUrl: baseUrl),
);

final tagRepositoryProvider = Provider(
  (ref) => TagRepositoryImpl(ref.watch(tagRemoteSourceProvider)),
);

final submitTagsUseCaseProvider = Provider(
  (ref) => SubmitTagsUseCase(ref.watch(tagRepositoryProvider)),
);

final tagControllerProvider =
    StateNotifierProvider<TagController, AsyncValue<void>>(
      (ref) => TagController(ref.watch(submitTagsUseCaseProvider)),
    );
