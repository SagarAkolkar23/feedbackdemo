import 'package:feedbackdemo/features/submitFeedback/domain/repository/feedbackRepo.dart';
import '../../domain/entity/feedbackEntity.dart';
import '../model/feedbackRequestModel.dart';
import '../source/feedbackRemoteDataSource.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FeedbackEntity> submitFeedback(FeedbackEntity entity, dynamic file) async {
    final request = FeedbackRequestModel(
      description: entity.description,
      tags: entity.tags,
      entityMentions: entity.entityMentions,
      entityId: entity.entityId,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
    );

    final response = await remoteDataSource.submitFeedback(request, file);

    return FeedbackEntity(
      description: entity.description,
      tags: entity.tags,
      entityMentions: entity.entityMentions,
      entityId: entity.entityId,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
      feedbackId: response.feedbackId,
    );
  }
}
