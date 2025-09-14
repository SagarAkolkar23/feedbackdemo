// data/sources/entity_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:feedbackdemo/features/details/data/model/entityModel.dart';

abstract class EntityRemoteDataSource {
  Future<EntityModel> registerEntity({
    required String serviceProviderName,
    required String state,
    required String city,
    required String pincode,
    required String industry,
    required String username,
  });
}

class EntityRemoteDataSourceImpl implements EntityRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  EntityRemoteDataSourceImpl(this.dio, {required this.baseUrl});

  @override
  Future<EntityModel> registerEntity({
    required String serviceProviderName,
    required String state,
    required String city,
    required String pincode,
    required String industry,
    required String username,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/register',
        data: {
          'service_provider_name': serviceProviderName,
          'state': state,
          'city': city,
          'pincode': pincode,
          'industry' : industry,
          'username': username,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Backend sends status 200 if success
      if (response.statusCode == 200) {
        return EntityModel.fromJson(response.data);
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } on DioError catch (e) {
      // Dio-specific error handling
      if (e.response != null) {
        throw Exception("Server error: ${e.response?.data}");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    }
  }
}
