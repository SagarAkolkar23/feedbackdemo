import 'package:dio/dio.dart';

abstract class GetTagRemoteDataSource {
  Future<List<String>> getAllTags({required String token});
}

class GetTagRemoteDataSourceImpl implements GetTagRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  GetTagRemoteDataSourceImpl(this.dio, {required this.baseUrl});

  @override
  Future<List<String>> getAllTags({required String token}) async {
    try {
      print("Fetching tags from $baseUrl/users/tags with token: $token");

      final response = await dio.get(
        "$baseUrl/users/tags",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("HTTP status code: ${response.statusCode}");
      print("Raw response data: ${response.data}");

      if (response.statusCode == 200) {
        final List data = response.data;

        // Map using the correct field
        final tags = data
            .map<String>((tag) => tag['tag_name']?.toString() ?? '')
            .where((tag) => tag.isNotEmpty)
            .toList();

        print("Mapped tags: $tags");
        return tags;
      } else {
        throw Exception("Failed to fetch tags: ${response.data}");
      }
    } catch (e) {
      print("Error fetching tags: $e");
      throw Exception("Error fetching tags: $e");
    }
  }
}
