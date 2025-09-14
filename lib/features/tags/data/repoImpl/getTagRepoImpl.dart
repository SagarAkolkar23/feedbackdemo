import 'package:feedbackdemo/features/tags/data/source/getTagsSource.dart';
import 'package:feedbackdemo/features/tags/domain/repo/getTagsRepo.dart';

class GetTagRepositoryImpl implements GetTagsRepository {
  final GetTagRemoteDataSource remoteSource;
  GetTagRepositoryImpl(this.remoteSource);

  @override
  Future<List<String>> getAllTags({required String token}) {
    return remoteSource.getAllTags(token: token);
  }
}
