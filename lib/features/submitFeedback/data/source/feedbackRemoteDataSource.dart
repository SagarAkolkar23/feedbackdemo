import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // 👈 for MediaType
import 'dart:html' as html;

import '../model/feedbackRequestModel.dart';
import '../model/feedbackResponseModel.dart';

class FeedbackRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  FeedbackRemoteDataSource({required this.client, required this.baseUrl});

  Future<FeedbackResponseModel> submitFeedback(
    FeedbackRequestModel feedback,
    dynamic file,
  ) async {
    final uri = Uri.parse('$baseUrl/feedback');
    final request = http.MultipartRequest('POST', uri);

    // Fields
    request.fields['description'] = feedback.description;
    request.fields['tags'] = jsonEncode(feedback.tags);
    request.fields['entityMentions'] = jsonEncode(feedback.entityMentions);

    if (feedback.entityId != null) {
      request.fields['entityId'] = feedback.entityId.toString();
    }
    if (feedback.userId != null) {
      request.fields['userId'] = feedback.userId.toString();
    }

    // File handling 🔥
    if (file != null) {
      if (file is File) {
        // Mobile
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      } else if (file is html.File) {
        // Web
        final reader = html.FileReader();
        final completer = Completer<List<int>>();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((_) {
          completer.complete(reader.result as List<int>);
        });
        final bytes = await completer.future;

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
            contentType: MediaType.parse(file.type),
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return FeedbackResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit feedback: ${response.body}');
    }
  }
}
