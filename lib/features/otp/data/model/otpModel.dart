class OtpRequestModel {
  final String phoneNumber;

  OtpRequestModel({required this.phoneNumber});

  Map<String, dynamic> toJson() => {"phn_number": phoneNumber};
}
