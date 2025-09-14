import 'package:feedbackdemo/features/details/domain/entity/entity.dart';

class EntityModel extends Entity {
  final String token; // From backend response

  const EntityModel({
    required String entityId,
    required String username,
    required this.token,
  }) : super(entityId: entityId, username: username, token: token);

  factory EntityModel.fromJson(Map<String, dynamic> json) {
    return EntityModel(
      entityId: json['entity']['entity_id'].toString(),
      username: json['entity']['username'],
      token: json['token'],
    );
  }
}
