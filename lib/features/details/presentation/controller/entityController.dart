
import 'package:feedbackdemo/features/details/domain/entity/entity.dart';
import 'package:feedbackdemo/features/details/domain/usecases/RegisterEntityUseCase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntityController extends StateNotifier<AsyncValue<Entity?>> {
  final RegisterEntityUseCase _registerEntityUseCase;

  EntityController(this._registerEntityUseCase)
    : super(const AsyncValue.data(null));

  /// Registers a new entity by calling the use case.
  Future<void> registerEntity({
    required String serviceProviderName,
    required String stateName,
    required String city,
    required String pincode,
    required String industry,
    required String email,
    required String description,
    required String username,
  }) async {
    // Set state to loading while API call is in progress
    state = const AsyncValue.loading();

    try {
      final entity = await _registerEntityUseCase(
        serviceProviderName: serviceProviderName,
        state: stateName,
        city: city,
        pincode: pincode,
        industry : industry,
        email: email,
        description: description,
        username: username,
      );

      // On success → update state with the new entity
      state = AsyncValue.data(entity);
    } catch (e, st) {
      // On error → store the error and stacktrace
      state = AsyncValue.error(e, st);
    }
  }
}
