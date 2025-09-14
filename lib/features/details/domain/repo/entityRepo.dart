import 'package:feedbackdemo/features/details/domain/entity/entity.dart';


abstract class EntityRepository {
  Future<Entity> registerEntity({
    required String serviceProviderName,
    required String state,
    required String city,
    required String pincode,
    required String industry,
    required String username,
  });
}
