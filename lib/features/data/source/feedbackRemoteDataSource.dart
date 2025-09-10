import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/feedbackRequestModel.dart';
import '../model/feedbackResponseModel.dart';

class FeedbackRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  FeedbackRemoteDataSource({required this.client, required this.baseUrl});

  Future<FeedbackResponseModel> submitFeedback(
    FeedbackRequestModel feedback,
    String token, // 👈 added token
  ) async {
    final uri = Uri.parse('$baseUrl/feedback');

    print("➡️ Submitting feedback to $uri");
    print("Payload: ${feedback.toJson()}");

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 👈 include token here
      },
      body: jsonEncode(feedback.toJson()),
    );

    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 201) {
      return FeedbackResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to submit feedback. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}
