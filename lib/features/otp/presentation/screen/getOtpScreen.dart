import 'package:feedbackdemo/features/details/presentation/provider/entityProvider.dart';
import 'package:feedbackdemo/features/otp/presentation/provider/otpProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GetOtpScreen extends ConsumerStatefulWidget {
  const GetOtpScreen({super.key});

  @override
  ConsumerState<GetOtpScreen> createState() => _GetOtpScreenState();
}

class _GetOtpScreenState extends ConsumerState<GetOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitOtp() {
    final entity = ref.read(entityControllerProvider).asData?.value;
    if (entity != null) {
      _requestOtp(_phoneController.text.trim(), entity.token);
    }
  }

  void _requestOtp(String phone, String token) async {
    if (!_formKey.currentState!.validate()) return;

    final phoneForRoute = _phoneController.text.trim();

    try {
      await ref.read(otpControllerProvider.notifier).requestOtp(phone, token);
      if (mounted) context.go("/verify-otp?phone=$phoneForRoute");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error requesting OTP: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpControllerProvider);
    final entityState = ref.watch(entityControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left side background image (desktop/tablet only)
          if (isDesktop)
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/Image/sideImage.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // Right side: Centered Logo + Form + Button
          Expanded(
            flex: 1,
            child: SafeArea(
              child: entityState.when(
                data: (entity) {
                  if (entity == null) {
                    return const Center(
                      child: Text(
                        "Could not load user details. Please try again.",
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 80 : 24,
                        vertical: 16,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                "assets/Image/Pictonion.png",
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 40),

                              // Register title
                              const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Phone number field
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submitOtp(),
                                decoration: const InputDecoration(
                                  hintText: "Enter Your Phone Number",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a phone number';
                                  }
                                  if (value.length < 10) {
                                    return 'Please enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Send OTP button
                              otpState.when(
                                data: (_) => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D63F3),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _submitOtp,
                                    child: const Text("Send OTP"),
                                  ),
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (err, st) => Text(
                                  "Error: $err",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: Text(
                    "Failed to load user data: $err",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
