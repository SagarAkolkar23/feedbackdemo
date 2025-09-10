import 'package:feedbackdemo/features/domain/repository/feedbackRepo.dart';
import '../../domain/entity/feedbackEntity.dart';
import '../model/feedbackRequestModel.dart';
import '../source/feedbackRemoteDataSource.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FeedbackEntity> submitFeedback(
    FeedbackEntity entity,
    String token, // 👈 added token param
  ) async {
    final request = FeedbackRequestModel(
      description: entity.description,
      isHappy: entity.isHappy,
      tags: entity.tags,
      entityMentions: entity.entityMentions,
      imageUrl: entity.imageUrl,
    );

    // 👇 pass token down
    final response = await remoteDataSource.submitFeedback(request, token);

    return FeedbackEntity(
      description: entity.description,
      isHappy: entity.isHappy,
      tags: entity.tags,
      entityMentions: entity.entityMentions,
      imageUrl: entity.imageUrl,
      feedbackId: response.feedbackId,
    );
  }
}
