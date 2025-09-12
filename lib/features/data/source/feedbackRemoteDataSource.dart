import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    String token,
    dynamic file, // 👈 File, XFile, or html.File
  ) async {
    final uri = Uri.parse('$baseUrl/feedback');

    print("➡️ Submitting feedback to $uri");

    final request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $token';

    // ✅ add form fields
    request.fields['description'] = feedback.description;
    request.fields['is_happy'] = feedback.isHappy.toString();
    request.fields['tags'] = jsonEncode(feedback.tags);
    request.fields['entityMentions'] = jsonEncode(feedback.entityMentions);

    // ✅ add file if available
    if (file != null) {
      if (file is File) {
        final ext = file.path.split('.').last.toLowerCase();
        final type = _getMediaType(ext);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // 👈 must match backend field name
            file.path,
            filename: file.path.split('/').last,
            contentType: type,
          ),
        );
      } else if (file is XFile) {
        final ext = file.path.split('.').last.toLowerCase();
        final type = _getMediaType(ext);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            filename: file.name,
            contentType: type,
          ),
        );
      } else if (kIsWeb && file is html.File) {
        final reader = html.FileReader();
        final completer = Completer<Uint8List>();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((_) {
          completer.complete(reader.result as Uint8List);
        });
        final bytes = await completer.future;

        final ext = file.name.split('.').last.toLowerCase();
        final type = _getMediaType(ext);

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: file.name,
            contentType: type,
          ),
        );
      }
    }

    // send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

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

  MediaType _getMediaType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
