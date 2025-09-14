class FeedbackEntity {
  final String description;
  final List<Map<String, dynamic>> tags; // each tag has 'tag_name' and 'is_happy'
  final int? entityId;
  final List<String> entityMentions;
  final String? imageUrl;
  final int? feedbackId;
  final int? userId; // add this to include userId from OTP

  FeedbackEntity({
    required this.description,
    required this.tags,
    required this.entityId,
    required this.entityMentions,
    this.imageUrl,
    this.feedbackId,
    this.userId,
  });
}

