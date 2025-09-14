class FeedbackRequestModel {
  final String description;
  final List<Map<String, dynamic>> tags;
  final int? entityId;
  final List<String> entityMentions;
  final String? imageUrl;
  final int? userId;

  FeedbackRequestModel({
    required this.description,
    required this.tags,
    required this.entityId,
    required this.entityMentions,
    this.imageUrl,
    this.userId,
  });
}
