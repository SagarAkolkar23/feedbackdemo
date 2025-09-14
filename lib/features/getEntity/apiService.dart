// services/api_service.dart
import 'dart:convert';
import 'package:feedbackdemo/features/getEntity/entityDetailsModel.dart';
import 'package:feedbackdemo/features/getEntity/entityFullModel.dart';
import 'package:feedbackdemo/features/getEntity/model.dart';
import 'package:feedbackdemo/features/getEntity/tagmodel.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://localhost:5005"; 

  /// Fetch all entities (basic info)
  static Future<List<Entity>> getAllEntities() async {
    final url = Uri.parse('$baseUrl/entity/get-entities');
    print('🔹 GET $url');

    final response = await http.get(url);
    print('🔹 Status: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((e) => Entity.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load entities');
    }
  }

  /// Fetch full details for a single entity
  static Future<EntityDetails> getEntityDetails(
    int entityId,
    String handle,
  ) async {
    final url = Uri.parse('$baseUrl/entity/details/$handle/$entityId');
    print('🔹 GET $url');

    final response = await http.get(url);
    print('🔹 Status: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      return EntityDetails.fromJson(json.decode(response.body)['entity']);
    } else {
      throw Exception('Failed to load entity details for id=$entityId');
    }
  }

  /// Fetch tags for a single entity
  static Future<List<Tag>> getEntityTags(int entityId) async {
    final url = Uri.parse('$baseUrl/entity/entity-tags/$entityId');
    print('🔹 GET $url');

    final response = await http.get(url);
    print('🔹 Status: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body)['tags'] ?? [];
      return jsonData.map((e) => Tag.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load entity tags for id=$entityId');
    }
  }

  /// Fetch full entity: details + tags
  static Future<EntityFull> getEntityFull(int entityId, String handle) async {
    print('🔹 Fetching full entity: id=$entityId, handle=$handle');

    try {
      final details = await getEntityDetails(entityId, handle);
      final tags = await getEntityTags(entityId);

      print(
        '🔹 Fetched entity details: ${details.name}, Tags count: ${tags.length}',
      );
      return EntityFull(details: details, tags: tags);
    } catch (e) {
      print('❌ Error fetching full entity: $e');
      rethrow;
    }
  }
}
