import 'dart:convert';

class FeedbackRequestModel {
  final String description;
  final bool isHappy;
  final List<String> tags;
  final List<String> entityMentions;
  final String? imageUrl; 

  FeedbackRequestModel({
    required this.description,
    required this.isHappy,
    required this.tags,
    required this.entityMentions,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'is_happy': isHappy,
    'tags': jsonEncode(tags),
    'entityMentions': jsonEncode(entityMentions),
    'image_url': imageUrl,
  };
}
