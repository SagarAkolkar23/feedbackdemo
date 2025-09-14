import 'package:feedbackdemo/features/tags/domain/repo/tagsRepo.dart';

class SubmitTagsUseCase {
  final TagRepository repository;

  SubmitTagsUseCase(this.repository);

  Future<void> call(List<String> tags, String token) {
    return repository.submitTags(tags, token);
  }
}
