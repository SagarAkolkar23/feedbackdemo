import 'package:feedbackdemo/features/tags/domain/repo/getTagsRepo.dart';

class GetTagsUseCase {
  final GetTagsRepository repository;
  GetTagsUseCase(this.repository);

  Future<List<String>> call({required String token}) async {
    return await repository.getAllTags(token: token);
  }
}
