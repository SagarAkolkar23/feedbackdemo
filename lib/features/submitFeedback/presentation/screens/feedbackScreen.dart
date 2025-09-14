import 'dart:io' show File;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:feedbackdemo/features/getEntity/entityDetailsModel.dart';
import 'package:feedbackdemo/features/getEntity/tagmodel.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/controllers/otpController.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/providers/feedbackProvider.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/controllers/feedbackController.dart';
import 'package:feedbackdemo/features/submitFeedback/domain/entity/feedbackEntity.dart';

import '../controllers/webCameraWidget.dart';
import 'package:feedbackdemo/features/getEntity/apiService.dart';

class FeedbackFormScreen extends ConsumerStatefulWidget {
  final int entityId;
  final String entityHandle;

  const FeedbackFormScreen({
    super.key,
    required this.entityId,
    required this.entityHandle,
  });

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _description;
  final Map<String, int> _tagRatings = {};
  final List<String> emojis = ["😕", "🙂"];
  final List<Color> ratingColors = [Colors.blue];
  dynamic _selectedMedia;
  final ImagePicker _picker = ImagePicker();

  late final String _videoPreviewViewType;
  late final html.VideoElement _videoPreviewElement;
  String? _videoPreviewUrl;

  EntityDetails? _entityDetails;
  List<Tag> _entityTags = [];
  bool _loadingDetails = true;
  bool _loadingTags = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize video preview for web
    if (kIsWeb) {
      _videoPreviewViewType = 'feedback-video-preview-${this.hashCode}';
      _videoPreviewElement = html.VideoElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..controls = true;

      ui_web.platformViewRegistry.registerViewFactory(
        _videoPreviewViewType,
        (int viewId) => _videoPreviewElement,
      );
    }

    _fetchEntityFull();
  }

  Future<void> _fetchEntityFull() async {
    setState(() {
      _loadingDetails = true;
      _loadingTags = true;
      _errorMessage = null;
    });

    try {
      final entityFull = await ApiService.getEntityFull(
        widget.entityId,
        widget.entityHandle,
      );

      if (!mounted) return;

      setState(() {
        _entityDetails = entityFull.details;
        _entityTags = entityFull.tags;
        _loadingDetails = false;
        _loadingTags = false;
      });

      print(
        '✅ Entity full loaded: ${_entityDetails?.name}, tags=${_entityTags.length}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load entity details & tags';
        _loadingDetails = false;
        _loadingTags = false;
      });
      print('❌ Error loading entity full: $e');
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _videoPreviewUrl != null) {
      html.Url.revokeObjectUrl(_videoPreviewUrl!);
    }
    super.dispose();
  }

  void _updateSelectedMedia(dynamic media) {
    if (!mounted) return;
    setState(() {
      _selectedMedia = media;
      if (kIsWeb) {
        if (_videoPreviewUrl != null) {
          html.Url.revokeObjectUrl(_videoPreviewUrl!);
          _videoPreviewUrl = null;
        }
        if (media is html.File && media.type.startsWith('video/')) {
          final newUrl = html.Url.createObjectUrl(media);
          _videoPreviewUrl = newUrl;
          _videoPreviewElement.src = newUrl;
        }
      }
    });
  }

  bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _chooseFromGallery() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*,video/*'
        ..click();
      await uploadInput.onChange.first;
      if (!mounted) return;
      final file = uploadInput.files?.first;
      if (file != null) _updateSelectedMedia(file);
    } else {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) _updateSelectedMedia(File(picked.path));
    }
  }

  void _onWebMediaCaptured(html.File media) {
    _updateSelectedMedia(media);
  }

  Future<void> _pickMediaFromCamera({required bool isVideo}) async {
    final picked = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) _updateSelectedMedia(File(picked.path));
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
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.indigo),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickMediaFromCamera(isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.indigo),
                title: const Text("Record Video"),
                onTap: () {
                  Navigator.pop(context);
                  _pickMediaFromCamera(isVideo: true);
                },
              ),
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
    } else if (_selectedMedia is File) {
      return (_selectedMedia as File).path.split('/').last;
    }
    return '';
  }

  bool isImage() {
    if (_selectedMedia == null) return false;
    if (kIsWeb && _selectedMedia is html.File) {
      return (_selectedMedia as html.File).type.startsWith('image/');
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
    } else if (_selectedMedia is File) {
      final ext = (_selectedMedia as File).path.split('.').last.toLowerCase();
      return ['mp4', 'mov', 'avi', 'webm'].contains(ext);
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
      data: (e) => e != null,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _loadingDetails
              ? 'Loading...'
              : "${_entityDetails?.name ?? 'Entity'} Feedback Form",
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Center(
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 24.0,
                            ),
                            child: Text(
                              (_entityDetails?.description != null &&
                                      _entityDetails!.description
                                          .trim()
                                          .isNotEmpty)
                                  ? _entityDetails!.description
                                  : "Description not available",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 32),
                          _buildMediaSection(),
                          const SizedBox(height: 40),
                          const Text(
                            "Feedback Categories",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _loadingTags
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  children: _entityTags
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 28.0,
                                          ),
                                          child: _buildRatingRow(
                                            label: entry.value.name,
                                            selectedValue:
                                                _tagRatings[entry.value.name],
                                            onSelect: (val) => setState(
                                              () =>
                                                  _tagRatings[entry
                                                          .value
                                                          .name] =
                                                      val,
                                            ),
                                            activeColor:
                                                ratingColors[entry.key %
                                                    ratingColors.length],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
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
                          _buildPhoneOtpField(otpCtrl, otpNotifier),
                          const SizedBox(height: 20),
                          if (otpNotifier.showOtpField)
                            _buildOtpVerification(otpNotifier),
                          _buildSubmitButton(
                            isOtpVerified,
                            feedbackCtrl,
                            feedbackNotifier,
                            otpNotifier,
                            otpCtrl,
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
        Expanded(
          flex: 2,
          child: kIsWeb
              ? Column(
                  children: [
                    WebCameraWidget(onMediaCaptured: _onWebMediaCaptured),
                    const SizedBox(height: 12),
                    Text("OR", style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: const Text("Choose from files"),
                      onPressed: _chooseFromGallery,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: BorderSide(color: Colors.indigo.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
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
                      cursor: SystemMouseCursors.click,
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
        Expanded(
          flex: 2,
          child: Container(
            // FIX: Give the container a fixed height to solve the unbounded height error.
            // This height matches the camera widget's default height for visual consistency.
            height: 220,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Builder(
                            builder: (context) {
                              if (isImage()) {
                                return kIsWeb
                                    ? Image.network(
                                        html.Url.createObjectUrl(
                                          _selectedMedia as html.File,
                                        ),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _selectedMedia as File,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                              } else if (isVideo()) {
                                return kIsWeb
                                    ? HtmlElementView(
                                        viewType: _videoPreviewViewType,
                                      )
                                    : const Center(
                                        child: Text(
                                          "🎥 Video preview not supported on mobile.",
                                        ),
                                      );
                              }
                              return const SizedBox.shrink();
                            },
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
                  cursor: SystemMouseCursors.click,
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
    AsyncValue otpCtrl,
  ) {
    return ElevatedButton(
      onPressed: () async {
        // Save form fields
        _formKey.currentState?.save();

        // Build tag-wise payload with is_happy
        final tagsPayload = _entityTags.map((tag) {
          final rating = _tagRatings[tag.name] ?? 0;
          final isHappy = rating == 1; // emoji index 1 = happy
          return {'tag_name': tag.name, 'is_happy': isHappy};
        }).toList();

        final finalDescription = _description ?? "";

        // Determine userId: only include if phone is verified
        final otpEntity = otpCtrl.asData?.value;
        final userId = (otpNotifier.isVerified && otpEntity != null)
            ? otpEntity.userId
            : null;

        // Create FeedbackEntity with userId optional
        final entity = FeedbackEntity(
          description: finalDescription,
          tags: tagsPayload,
          entityId: widget.entityId,
          entityMentions: [],
          imageUrl: getSelectedFileName(),
          feedbackId: null,
          userId: userId, // include verified userId here
        );

        await feedbackNotifier.submitFeedback(entity, _selectedMedia);

        // Handle submission state
        final state = ref.read(feedbackControllerProvider);
        state.when(
          data: (_) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Feedback submitted 🎉")),
          ),
          loading: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Submitting... ⏳"))),
          error: (e, _) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Submission failed ❌: $e"))),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.indigo,
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
