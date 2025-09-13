import 'dart:io' show File;
import 'package:feedbackdemo/features/getEntity/entityDetailsModel.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'package:feedbackdemo/features/submitFeedback/presentation/controllers/otpController.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/providers/feedbackProvider.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/controllers/feedbackController.dart';
import '../../domain/entity/feedbackEntity.dart';


class FeedbackFormScreen extends ConsumerStatefulWidget {
  final List<String> tags;
  final int entityId;
  final EntityDetails? entityDetails;

  const FeedbackFormScreen({
    super.key,
    required this.entityId,
    required this.tags,
    required this.entityDetails,
  });

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _description;

  final Map<String, int> _tagRatings = {};
  final List<String> emojis = ["😕", "🙂"];
  final List<Color> ratingColors = [
    Colors.blue,
    
  ];

  dynamic _selectedMedia;
  final ImagePicker _picker = ImagePicker();

  bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _pickMedia({required bool isVideo}) async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*,video/*'
        ..click();
      await uploadInput.onChange.first;
      final file = uploadInput.files?.first;
      if (file != null) setState(() => _selectedMedia = file);
    } else {
      final picked = isVideo
          ? await _picker.pickVideo(source: ImageSource.camera)
          : await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) setState(() => _selectedMedia = picked);
    }
  }

  Future<void> _chooseFromGallery() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*,video/*'
        ..click();
      await uploadInput.onChange.first;
      final file = uploadInput.files?.first;
      if (file != null) setState(() => _selectedMedia = file);
    } else {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) setState(() => _selectedMedia = picked);
    }
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isMobile) ...[
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.indigo),
                  title: const Text("Take Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia(isVideo: false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam, color: Colors.indigo),
                  title: const Text("Record Video"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia(isVideo: true);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.indigo),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _chooseFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String getSelectedFileName() {
    if (_selectedMedia == null) return '';
    if (kIsWeb && _selectedMedia is html.File) {
      return (_selectedMedia as html.File).name;
    } else if (_selectedMedia is XFile) {
      return (_selectedMedia as XFile).name;
    } else if (_selectedMedia is File) {
      return (_selectedMedia as File).path.split('/').last;
    }
    return '';
  }

  bool isImage() {
    if (_selectedMedia == null) return false;
    if (kIsWeb && _selectedMedia is html.File) {
      return (_selectedMedia as html.File).type.startsWith('image/');
    } else if (_selectedMedia is XFile) {
      final ext = (_selectedMedia as XFile).name.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
    } else if (_selectedMedia is File) {
      final ext = (_selectedMedia as File).path.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
    }
    return false;
  }

  bool isVideo() {
    if (_selectedMedia == null) return false;
    if (kIsWeb && _selectedMedia is html.File) {
      return (_selectedMedia as html.File).type.startsWith('video/');
    } else if (_selectedMedia is XFile) {
      final ext = (_selectedMedia as XFile).name.split('.').last.toLowerCase();
      return ['mp4', 'mov', 'avi'].contains(ext);
    } else if (_selectedMedia is File) {
      final ext = (_selectedMedia as File).path.split('.').last.toLowerCase();
      return ['mp4', 'mov', 'avi'].contains(ext);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final otpCtrl = ref.watch(otpControllerProvider);
    final otpNotifier = ref.read(otpControllerProvider.notifier);
    final feedbackCtrl = ref.watch(feedbackControllerProvider);
    final feedbackNotifier = ref.read(feedbackControllerProvider.notifier);

    final isOtpVerified = otpCtrl.maybeWhen(
      data: (entity) => entity != null,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("${widget.entityDetails?.name ?? 'Entity'} Feedback Form"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "We value your feedback 💬",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Help us improve by sharing your experience.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    /// Media upload
                    _buildMediaSection(),
                    const SizedBox(height: 40),

                    /// Ratings per tag
                    const SizedBox(height: 20),
                    const Text(
                      "Feedback Categories",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 20),

                    ...widget.tags.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tag = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 28.0),
                        child: _buildRatingRow(
                          label: tag,
                          selectedValue: _tagRatings[tag],
                          onSelect: (val) =>
                              setState(() => _tagRatings[tag] = val),
                          activeColor:
                              ratingColors[index % ratingColors.length],
                        ),
                      );
                    }).toList(),


                    /// Description
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Feedback description (optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      minLines: 3,
                      maxLines: 5,
                      onSaved: (val) => _description = val,
                    ),
                    const SizedBox(height: 28),

                    /// Phone instructions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        "* Please provide your mobile number so we can keep you updated on the progress of your feedback.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    /// Phone with OTP
                    _buildPhoneOtpField(otpCtrl, otpNotifier),
                    const SizedBox(height: 20),

                    /// OTP verification field
                    if (otpNotifier.showOtpField)
                      _buildOtpVerification(otpNotifier),

                    /// Submit button
                    _buildSubmitButton(
                      isOtpVerified,
                      feedbackCtrl,
                      feedbackNotifier,
                      otpNotifier,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Left: Camera upload
        /// Left: Camera upload
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const Text(
                "Upload / Capture",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 12),
              MouseRegion(
                cursor: SystemMouseCursors.click, // 👈 hand cursor
                child: GestureDetector(
                  onTap: _showMediaOptions,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo.shade200),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.indigo.shade50,
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Click here to take a photo/video\nor upload from gallery",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        /// Right: Preview
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: _selectedMedia != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected: ${getSelectedFileName()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isImage())
                        kIsWeb
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  html.Url.createObjectUrlFromBlob(
                                    _selectedMedia as html.File,
                                  ),
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedMedia as File,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      if (isVideo())
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "🎥 Video selected (preview not supported)",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                    ],
                  )
                : const Center(
                    child: Text(
                      "No file selected yet.\nUpload or capture to preview here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

 Widget _buildPhoneOtpField(AsyncValue otpCtrl, OtpController otpNotifier) {  
    return Stack(
      children: [
        TextFormField(
          onChanged: (val) => ref.read(feedbackProvider.notifier).state = val,
          decoration: InputDecoration(
            labelText: "Phone number (optional)",
            hintText: "+91 98765 43210",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.phone,
          readOnly: otpNotifier.showOtpField || otpNotifier.isVerified,
        ),
        Positioned(
          right: 12,
          top: 12,
          child: otpNotifier.isVerified
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : MouseRegion(
                  cursor: SystemMouseCursors.click, // 👈 hand cursor
                  child: GestureDetector(
                    onTap: () async {
                      final phone = ref.read(feedbackProvider) ?? "";
                      if (phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("⚠️ Enter phone number"),
                          ),
                        );
                        return;
                      }
                      await otpNotifier.sendOtp(phone);
                      final state = ref.read(otpControllerProvider);
                      state.whenOrNull(
                        data: (_) {
                          otpNotifier.startOtpTimer();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("OTP Sent ✅")),
                          );
                        },
                        error: (e, _) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to send OTP ❌: $e"),
                              ),
                            ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: otpCtrl is AsyncLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              "Get OTP",
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
        ),

      ],
    );
  }

  Widget _buildOtpVerification(OtpController otpNotifier) {
    if (otpNotifier.isVerified) {
      // ✅ Number verified → hide OTP UI completely
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: otpNotifier.otpController,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: otpNotifier.secondsRemaining / 120,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.indigoAccent,
                    ),
                    strokeWidth: 4,
                  ),
                  Text(
                    otpNotifier.formattedTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ✅ Verify button (visible until success)
        ElevatedButton(
          onPressed: () async {
            final phone = ref.read(feedbackProvider) ?? "";
            if (phone.isEmpty) return;

            await otpNotifier.verifyOtp(phone);
            final state = ref.read(otpControllerProvider);
            state.whenOrNull(
              data: (_) {
                if (otpNotifier.isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP Verified ✅")),
                  );
                }
              },
              error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("OTP Verification Failed ❌: $e")),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            "Verify OTP",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        const SizedBox(height: 28),
      ],
    );
  }


  Widget _buildSubmitButton(
    bool isOtpVerified,
    AsyncValue feedbackCtrl,
    FeedbackController feedbackNotifier,
    OtpController otpNotifier,
  ) {
    return ElevatedButton(
      onPressed: isOtpVerified
          ? () async {
              _formKey.currentState?.save();

              final happyCount = _tagRatings.values
                  .where((rating) => rating == 1)
                  .length;
              final isHappyOverall = happyCount >= (_tagRatings.length / 2);

              final ratingsDetail = _tagRatings.entries
                  .map((e) {
                    final emoji = e.value < emojis.length
                        ? emojis[e.value]
                        : 'N/A';
                    return '${e.key}: $emoji';
                  })
                  .join(' | ');

              final finalDescription =
                  '${_description ?? ""}\n\n--- Ratings ---\n$ratingsDetail';

              final entity = FeedbackEntity(
                description: finalDescription,
                isHappy: isHappyOverall,
                tags: widget.tags,
                entityMentions: [],
                imageUrl: getSelectedFileName(),
              );

              final otpState = ref.read(otpControllerProvider);
              final token = otpState.value?.token ?? "";
              if (token.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("⚠️ Missing access token")),
                );
                return;
              }

              await feedbackNotifier.submitFeedback(
                entity,
                token,
                _selectedMedia,
              );

              final state = ref.read(feedbackControllerProvider);
              state.when(
                data: (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Feedback submitted 🎉")),
                ),
                loading: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Submitting... ⏳")),
                ),
                error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Submission failed ❌: $e")),
                ),
              );
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⚠️ Please verify OTP before submitting."),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isOtpVerified ? Colors.indigo : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: feedbackCtrl is AsyncLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              "Submit Feedback",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildRatingRow({
    required String label,
    required int? selectedValue,
    required Function(int) onSelect,
    required Color activeColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(emojis.length, (index) {
              final isSelected = selectedValue == index;
              return GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? activeColor.withOpacity(0.15)
                        : Colors.transparent,
                  ),
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
