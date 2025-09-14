class EntityDetails {
  final int id;
  final String name;
  final String handle;
  final String createdAt;
  final String state;
  final String city;
  final String pincode; // keep as String (force convert)
  final String email;
  final String description;
  final String industry;

  EntityDetails({
    required this.id,
    required this.name,
    required this.handle,
    required this.createdAt,
    required this.state,
    required this.city,
    required this.pincode,
    required this.description,
    required this.email,
    required this.industry,
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
      email: json['email']?.toString() ?? '',
      description: json['description'] ?? '',
      industry: json['industry'] ?? '',
    );
  }
}
