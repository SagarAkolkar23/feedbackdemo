import 'package:feedbackdemo/features/details/domain/entity/entity.dart';
import 'package:feedbackdemo/features/details/domain/repo/entityRepo.dart';

class RegisterEntityUseCase {
  final EntityRepository repository;

  RegisterEntityUseCase(this.repository);

  Future<Entity> call({
    required String serviceProviderName,
    required String state,
    required String city,
    required String pincode,
    required String industry,
    required String username,
  }) {
    // Business logic (if needed) before sending to repository
    return repository.registerEntity(
      serviceProviderName: serviceProviderName,
      state: state,
      city: city,
      pincode: pincode,
      industry : industry,
      username: username,
    );
  }
}
