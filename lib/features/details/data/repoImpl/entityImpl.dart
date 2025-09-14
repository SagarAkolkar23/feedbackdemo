

import 'package:feedbackdemo/features/details/data/source/entityRemoteSource.dart';
import 'package:feedbackdemo/features/details/domain/entity/entity.dart';
import 'package:feedbackdemo/features/details/domain/repo/entityRepo.dart';

class EntityRepositoryImpl implements EntityRepository {
  final EntityRemoteDataSource remoteDataSource;

  EntityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Entity> registerEntity({
    required String serviceProviderName,
    required String state,
    required String city,
    required String pincode,
    required String industry,
    required String username,
  }) {
    return remoteDataSource.registerEntity(
      serviceProviderName: serviceProviderName,
      state: state,
      city: city,
      pincode: pincode,
      industry : industry,
      username: username,
    );
  }
}
