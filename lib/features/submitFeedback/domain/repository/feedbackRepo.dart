import '../entity/feedbackEntity.dart';

abstract class FeedbackRepository {
  Future<FeedbackEntity> submitFeedback(
    FeedbackEntity entity,
    String token, 
    dynamic file
  );
}
