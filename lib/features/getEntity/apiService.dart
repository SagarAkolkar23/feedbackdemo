// services/api_service.dart
import 'dart:convert';
import 'package:feedbackdemo/features/getEntity/entityDetailsModel.dart';
import 'package:feedbackdemo/features/getEntity/entityFullModel.dart';
import 'package:feedbackdemo/features/getEntity/model.dart';
import 'package:feedbackdemo/features/getEntity/tagmodel.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://localhost:5005"; // replace with your backend URL

  static Future<List<Entity>> getAllEntities() async {
    final response = await http.get(Uri.parse('$baseUrl/entity/get-entities'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((e) => Entity.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load entities');
    }
  }

  static Future<EntityDetails> getEntityDetails(
    int entityId,
    String handle,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/entity/details/$handle/$entityId'),
    );

    if (response.statusCode == 200) {
      return EntityDetails.fromJson(json.decode(response.body)['entity']);
    } else {
      throw Exception('Failed to load entity details');
    }
  }

  static Future<List<Tag>> getEntityTags(int entityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/entity/entity-tags/$entityId'),
    );

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body)['tags'];
      return jsonData.map((e) => Tag.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load entity tags');
    }
  }

   static Future<EntityFull> getEntityFull(int entityId, String handle) async {
    final details = await getEntityDetails(entityId, handle);
    final tags = await getEntityTags(entityId);

    return EntityFull(details: details, tags: tags);
  }
}
