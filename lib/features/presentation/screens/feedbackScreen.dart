import 'dart:async';
import 'dart:io' show File;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'package:feedbackdemo/features/presentation/controllers/otpController.dart';
import 'package:feedbackdemo/features/presentation/providers/feedbackProvider.dart';
import 'package:feedbackdemo/features/presentation/controllers/feedbackController.dart';
import '../../domain/entity/feedbackEntity.dart';

class FeedbackFormScreen extends ConsumerStatefulWidget {
  final List<String> tags;
  final int entityId;
  const FeedbackFormScreen({super.key,required this.entityId, required this.tags});

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _description;
  int? _qualityRating;
  int? _experienceRating;
  final List<String> emojis = ["😕", "🙂"];

  dynamic _selectedMedia;
  final ImagePicker _picker = ImagePicker();

  bool get isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _pickMedia({required bool isVideo}) async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*,video/*';
      uploadInput.click();
      await uploadInput.onChange.first;
      final file = uploadInput.files?.first;
      if (file != null) setState(() => _selectedMedia = file);
    } else {
      XFile? picked;
      if (isVideo) {
        picked = await _picker.pickVideo(source: ImageSource.camera);
      } else {
        picked = await _picker.pickImage(source: ImageSource.camera);
      }
      if (picked != null) setState(() => _selectedMedia = picked);
    }
  }

  Future<void> _chooseFromGallery() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*,video/*';
      uploadInput.click();
      await uploadInput.onChange.first;
      final file = uploadInput.files?.first;
      if (file != null) setState(() => _selectedMedia = file);
    } else {
      XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
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
    } else if (!kIsWeb && _selectedMedia is XFile) {
      return (_selectedMedia as XFile).name;
    } else if (!kIsWeb && _selectedMedia is File) {
      return (_selectedMedia as File).path.split('/').last;
    }
    return '';
  }

  bool isImage() {
    if (_selectedMedia == null) return false;
    if (kIsWeb && _selectedMedia is html.File) {
      return (_selectedMedia as html.File).type.startsWith('image/');
    } else if (!kIsWeb && _selectedMedia is XFile) {
      final ext = (_selectedMedia as XFile).name.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
    } else if (!kIsWeb && _selectedMedia is File) {
      final ext = (_selectedMedia as File).path.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
    }
    return false;
  }

  bool isVideo() {
    if (_selectedMedia == null) return false;
    if (kIsWeb && _selectedMedia is html.File) {
      return (_selectedMedia as html.File).type.startsWith('video/');
    } else if (!kIsWeb && _selectedMedia is XFile) {
      final ext = (_selectedMedia as XFile).name.split('.').last.toLowerCase();
      return ['mp4', 'mov', 'avi'].contains(ext);
    } else if (!kIsWeb && _selectedMedia is File) {
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
        title: const Text("Mobile Feedback Form"),
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

                    //TAGS SECTION
                    if (widget.tags.isNotEmpty) ...[
                      const Text(
                        "Feedback Categories:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.indigo.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Media upload
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: _showMediaOptions,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: _selectedMedia != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Selected: ${getSelectedFileName()}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (isImage())
                                        kIsWeb
                                            ? Image.network(
                                                html.Url.createObjectUrlFromBlob(
                                                  _selectedMedia as html.File,
                                                ),
                                                height: 150,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                _selectedMedia as File,
                                                height: 150,
                                                fit: BoxFit.cover,
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
                                : const Text(
                                    "Upload or take a photo/video of the product.",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Ratings
                    _buildRatingRow(
                      label: "Rate Overall Quality",
                      selectedValue: _qualityRating,
                      onSelect: (val) => setState(() => _qualityRating = val),
                      activeColor: Colors.blue,
                    ),
                    const SizedBox(height: 28),
                    _buildRatingRow(
                      label: "Rate User Experience",
                      selectedValue: _experienceRating,
                      onSelect: (val) =>
                          setState(() => _experienceRating = val),
                      activeColor: Colors.green,
                    ),
                    const SizedBox(height: 40),

                    // Description
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Feedback description",
                        hintText: "Share your thoughts (optional)...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      minLines: 3,
                      maxLines: 5,
                      onSaved: (val) => _description = val,
                    ),
                    const SizedBox(height: 28),

                    // Phone with Get OTP
                    Stack(
                      children: [
                        TextFormField(
                          onChanged: (val) =>
                              ref.read(feedbackProvider.notifier).state =
                                  val, // update provider state
                          decoration: InputDecoration(
                            labelText: "Phone number",
                            hintText: "+91 98765 43210",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          readOnly: otpNotifier.showOtpField,
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
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
                                        content: Text(
                                          "Failed to send OTP ❌: $e",
                                        ),
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
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
                      ],
                    ),
                    const SizedBox(height: 20),

                    // OTP verify
                    if (otpNotifier.showOtpField) ...[
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
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
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
                      ElevatedButton(
                        onPressed: () async {
                          final phone = ref.read(feedbackProvider) ?? "";
                          if (phone.isEmpty) return;

                          await otpNotifier.verifyOtp(phone);

                          final state = ref.read(otpControllerProvider);
                          state.whenOrNull(
                            data: (_) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("OTP Verified ✅"),
                                  ),
                                ),
                            error: (e, _) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "OTP Verification Failed ❌: $e",
                                    ),
                                  ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    ElevatedButton(
                      onPressed: isOtpVerified
                          ? () async {
                              _formKey.currentState?.save();

                              final entity = FeedbackEntity(
                                description: _description ?? "",
                                isHappy: (_qualityRating ?? 0) == 1,
                                tags: widget.tags,
                                entityMentions: [],
                                imageUrl: getSelectedFileName(),
                              );

                              final otpState = ref.read(otpControllerProvider);
                              final token = otpState.value?.token ?? "";

                              if (token.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("⚠️ Missing access token"),
                                  ),
                                );
                                return;
                              }

                              await feedbackNotifier.submitFeedback(
                                entity,
                                token,
                                _selectedMedia,
                              );

                              final state = ref.read(
                                feedbackControllerProvider,
                              );
                              state.when(
                                data: (_) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Feedback submitted 🎉"),
                                      ),
                                    ),
                                loading: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Submitting... ⏳"),
                                      ),
                                    ),
                                error: (e, _) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Submission failed ❌: $e",
                                        ),
                                      ),
                                    ),
                              );
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "⚠️ Please verify OTP before submitting.",
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isOtpVerified
                            ? Colors.indigo
                            : Colors.grey,
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
