class FeedbackEntity {
  final String description;
  final bool isHappy;
  final List<String> tags;
  final List<String> entityMentions;
  final String? imageUrl;
  final int? feedbackId;

  FeedbackEntity({
    required this.description,
    required this.isHappy,
    required this.tags,
    required this.entityMentions,
    this.imageUrl,
    this.feedbackId,
  });
}
