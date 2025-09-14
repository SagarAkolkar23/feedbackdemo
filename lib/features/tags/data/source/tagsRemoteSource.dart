import 'package:dio/dio.dart';

abstract class TagRemoteDataSource {
  Future<void> submitTags({
    required List<String> tags,
    required String token, // <— pass JWT here
  });
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  TagRemoteDataSourceImpl(this.dio, {required this.baseUrl});

  @override
  Future<void> submitTags({
    required List<String> tags,
    required String token,
  }) async {
    final response = await dio.post(
      "$baseUrl/entity/submit-tags",
      options: Options(
        headers: {
          "Authorization": "Bearer $token", 
          "Content-Type": "application/json",
        },
      ),
      data: {"tags": tags},
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to submit tags: ${response.data}");
    }
  }
}
