class FeedbackResponseModel {
  final String message;
  final int feedbackId;

  FeedbackResponseModel({required this.message, required this.feedbackId});

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedbackResponseModel(
      message: json['message'],
      feedbackId: json['feedbackId'],
    );
  }
}
