import '../entity/feedbackEntity.dart';

abstract class FeedbackRepository {
  Future<FeedbackEntity> submitFeedback(
    FeedbackEntity entity, // only one entity object
    dynamic file,
  );
}

