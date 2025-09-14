
import 'package:feedbackdemo/features/tags/data/source/tagsRemoteSource.dart';
import 'package:feedbackdemo/features/tags/domain/repo/tagsRepo.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submitTags(List<String> tags, String token) {
    return remoteDataSource.submitTags(tags: tags, token: token);
  }
}
