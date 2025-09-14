import 'package:feedbackdemo/features/tags/domain/useCase.dart/tagUseCase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagController extends StateNotifier<AsyncValue<void>> {
  final SubmitTagsUseCase submitTagsUseCase;

  TagController(this.submitTagsUseCase) : super(const AsyncValue.data(null));

  Future<void> submitTags(List<String> tags, String token) async {
    state = const AsyncValue.loading();
    try {
      await submitTagsUseCase(tags, token);
      state = const AsyncValue.data(null); // success
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
