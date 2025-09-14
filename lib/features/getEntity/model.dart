class Entity {
  final int id;
  final String handle;

  Entity({
    required this.id,
    required this.handle,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['entity_id'],
      handle: json['entity_handle'],
    );
  }
}
