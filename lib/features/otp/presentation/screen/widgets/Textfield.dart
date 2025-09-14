import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String heading;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType; // useful for numbers like pincode
  final bool isRequired;

  const CustomTextField({
    super.key,
    required this.heading,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return "$heading cannot be empty";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
