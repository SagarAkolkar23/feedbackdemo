import 'package:feedbackdemo/features/details/presentation/provider/entityProvider.dart';
import 'package:feedbackdemo/features/details/presentation/screen/widgets/textField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyDetailsPage extends ConsumerStatefulWidget {
  const CompanyDetailsPage({super.key});

  @override
  ConsumerState<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends ConsumerState<CompanyDetailsPage> {
  final TextEditingController serviceProviderController =
      TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Focus nodes to handle "Next" navigation
  final _serviceProviderFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _pincodeFocus = FocusNode();
  final _industryFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  @override
  void dispose() {
    serviceProviderController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    industryController.dispose();
    userNameController.dispose();
    emailController.dispose();
    descriptionController.dispose();

    _serviceProviderFocus.dispose();
    _stateFocus.dispose();
    _cityFocus.dispose();
    _pincodeFocus.dispose();
    _industryFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entityState = ref.watch(entityControllerProvider);

    ref.listen(entityControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (entity) {
          if (entity != null) {
            context.go("/tagselection");
          }
        },
      );
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Row(
            children: [
              if (!isMobile) // Hide left image on small screens
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

              // Form section
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Top Logo
                          Image.asset(
                            "assets/Image/Pictonion.png",
                            height: 70,
                            width: 250,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 15),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Enter your company details",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Input fields with "Next" navigation
                          CustomTextField(
                            heading: "Service Provider Name",
                            hintText: "Enter Service Provider Name",
                            controller: serviceProviderController,
                            focusNode: _serviceProviderFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_stateFocus);
                            },
                          ),
                          CustomTextField(
                            heading: "State",
                            hintText: "Enter State Name",
                            controller: stateController,
                            focusNode: _stateFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_cityFocus);
                            },
                          ),
                          CustomTextField(
                            heading: "City",
                            hintText: "Enter City Name",
                            controller: cityController,
                            focusNode: _cityFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_pincodeFocus);
                            },
                          ),
                          CustomTextField(
                            heading: "Pincode",
                            hintText: "Enter Pincode",
                            controller: pincodeController,
                            focusNode: _pincodeFocus,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_industryFocus);
                            },
                          ),
                          CustomTextField(
                            heading: "Industry",
                            hintText: "Enter Industry",
                            controller: industryController,
                            focusNode: _industryFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_emailFocus);
                            },
                          ),
                          CustomTextField(
                            heading: "Email",
                            hintText: "Enter your Email",
                            controller: emailController,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_descriptionFocus);
                            },
                          ),
                          CustomTextField(
                            heading: "Description",
                            hintText: "Enter Description",
                            controller: descriptionController,
                            focusNode: _descriptionFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_usernameFocus);
                            },
                          ),
                          CustomTextField(
                            heading: "User Name",
                            hintText: "Enter User Name",
                            controller: userNameController,
                            focusNode: _usernameFocus,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              _submitForm(entityState);
                            },
                          ),

                          const SizedBox(height: 20),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: entityState.isLoading
                                  ? null
                                  : () => _submitForm(entityState),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: entityState.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "NEXT",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          entityState.when(
                            data: (entity) => entity == null
                                ? const SizedBox.shrink()
                                : const Text(
                                    "✅ Registered successfully!",
                                    style: TextStyle(color: Colors.green),
                                  ),
                            loading: () => const SizedBox.shrink(),
                            error: (err, _) => Text(
                              "❌ Error: $err",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitForm(AsyncValue entityState) async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(entityControllerProvider.notifier)
          .registerEntity(
            serviceProviderName: serviceProviderController.text,
            stateName: stateController.text,
            city: cityController.text,
            pincode: pincodeController.text,
            industry: industryController.text,
            email: emailController.text,
            description: descriptionController.text,
            username: userNameController.text,
          );
    }
  }
}
