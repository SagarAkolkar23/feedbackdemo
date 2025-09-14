import 'package:feedbackdemo/features/tags/domain/entity/tagsEntity.dart';

class TagModel extends Tag {
  TagModel({required String name}) : super(name: name);

  Map<String, dynamic> toJson() => {
    "tags": [name], // backend expects an array
  };

  static List<Map<String, dynamic>> listToJson(List<Tag> tags) {
    return [
      {"tags": tags.map((e) => e.name).toList()},
    ];
  }
}
