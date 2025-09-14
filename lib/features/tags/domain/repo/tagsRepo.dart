
abstract class TagRepository {
  Future<void> submitTags(List<String> tags, String token);
}

// features/tags/domain/repository/tagsRepository.dart
abstract class TagsRepository {
  Future<void> submitTags(List<String> tags, String token);
  Future<List<String>> getAllTags(); // ✅ new
}


