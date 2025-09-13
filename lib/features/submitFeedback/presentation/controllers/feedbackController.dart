import 'package:feedbackdemo/features/submitFeedback/presentation/providers/feedbackProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/feedbackEntity.dart';

final feedbackControllerProvider =
    StateNotifierProvider<FeedbackController, AsyncValue<FeedbackEntity?>>(
      (ref) => FeedbackController(ref),
    );

class FeedbackController extends StateNotifier<AsyncValue<FeedbackEntity?>> {
  final Ref ref;

  FeedbackController(this.ref) : super(const AsyncValue.data(null));

  Future<void> submitFeedback(FeedbackEntity entity, String token, dynamic file) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(feedbackRepositoryProvider);
      final result = await repo.submitFeedback(entity, token, file); 
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
