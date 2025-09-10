import 'dart:convert';
import 'package:feedbackdemo/features/data/model/otpResponseModel.dart';
import 'package:http/http.dart' as http;

class OtpRemoteDataSource {
  final http.Client client;
  final String baseUrl = "http://localhost:5005";

  OtpRemoteDataSource({required this.client});

  Future<OtpResponseModel> sendOtp(String phone) async {
    try {
      final uri = Uri.parse("$baseUrl/auth/get-otp");
      print("➡️ Sending OTP request to $uri with phone: $phone");

      final response = await client.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phn_number": phone}),
      );

      print("⬅️ Response Status: ${response.statusCode}");
      print("⬅️ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return OtpResponseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Failed to send OTP. Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Exception in sendOtp: $e");
      rethrow;
    }
  }

  Future<OtpResponseModel> verifyOtp(String phone, String otp) async {
    try {
      final uri = Uri.parse("$baseUrl/auth/login");
      print("➡️ Verifying OTP at $uri with phone: $phone, otp: $otp");

      final response = await client.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phn_number": phone, "otp": otp}),
      );

      print("⬅️ Response Status: ${response.statusCode}");
      print("⬅️ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return OtpResponseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          "Failed to verify OTP. Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Exception in verifyOtp: $e");
      rethrow;
    }
  }
}
