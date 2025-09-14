abstract class TagRepository {
  Future<void> submitTags(List<String> tags, String token);
}
