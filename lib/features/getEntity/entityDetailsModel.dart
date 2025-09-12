class EntityDetails {
  final int id;
  final String name;
  final String handle;
  final String createdAt;
  final String state;
  final String city;
  final String pincode; // keep as String (force convert)
  final String industry;
  final String description;

  EntityDetails({
    required this.id,
    required this.name,
    required this.handle,
    required this.createdAt,
    required this.state,
    required this.city,
    required this.pincode,
    required this.industry,
    required this.description,
  });

  factory EntityDetails.fromJson(Map<String, dynamic> json) {
    return EntityDetails(
      id: json['id'],
      name: json['name'] ?? '',
      handle: json['handle'] ?? '',
      createdAt: json['createdAt'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode']?.toString() ?? '', // 🔑 Convert to String
      industry: json['industry'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
