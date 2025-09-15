// lib/features/submitFeedback/presentation/controllers/webCameraWidget.dart

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebCameraWidget extends StatefulWidget {
  final void Function(html.File media) onMediaCaptured;
  final double height;

  const WebCameraWidget({
    Key? key,
    required this.onMediaCaptured,
    this.height = 220,
  }) : super(key: key);

  @override
  State<WebCameraWidget> createState() => _WebCameraWidgetState();
}

class _WebCameraWidgetState extends State<WebCameraWidget> {
  late final String _viewType;
  late final html.DivElement _cameraContainerElement;

  html.VideoElement? _videoElement;
  Key _cameraViewKey = UniqueKey();

  html.MediaStream? _localStream;
  html.MediaRecorder? _recorder;
  final List<html.Blob> _recordedBlobs = [];
  bool _isRecording = false;
  bool _cameraInitialized = false;
  bool _showCamera = false;

  html.Blob? _capturedBlob;
  String? _capturedBlobType;
  String? _previewUrl;
  bool get _isInPreviewMode => _capturedBlob != null;

  String? _cameraError;

  // 🔹 Camera devices
  List<html.MediaDeviceInfo> _videoDevices = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();

    _viewType = 'web-camera-view-${this.hashCode}';
    _cameraContainerElement = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _cameraContainerElement,
    );

    _loadAvailableCameras();
  }

  Future<void> _loadAvailableCameras() async {
try {
      final devices = await html.window.navigator.mediaDevices!
          .enumerateDevices();
      final mediaDevices = devices.cast<html.MediaDeviceInfo>();

      setState(() {
        _videoDevices = mediaDevices
            .where((d) => d.kind == 'videoinput')
            .toList();
      });
    } catch (e) {
      debugPrint("Error fetching devices: $e");
    }

  }

  void _clearCameraView() {
    _cameraContainerElement.children.clear();
  }

  void _resetCaptureState() {
    if (_previewUrl != null) {
      html.Url.revokeObjectUrl(_previewUrl!);
    }
    if (!mounted) return;
    setState(() {
      _capturedBlob = null;
      _previewUrl = null;
      _capturedBlobType = null;
    });
  }

  Future<void> _initCamera() async {
    _resetCaptureState();
    _clearCameraView();
    if (!mounted) return;

    setState(() {
      _cameraError = null;
      _cameraViewKey = UniqueKey();
    });

    try {
      final constraints = {
        'video': _videoDevices.isNotEmpty
            ? {'deviceId': _videoDevices[_selectedCameraIndex].deviceId}
            : true,
        'audio': true,
      };

      final stream = await html.window.navigator.mediaDevices!.getUserMedia(
        constraints,
      );

      if (!mounted) {
        stream.getTracks().forEach((track) => track.stop());
        return;
      }
      _localStream = stream;

      _videoElement = html.VideoElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..autoplay = true
        ..muted = true
        ..srcObject = stream;

      _cameraContainerElement.children.add(_videoElement!);

      setState(() => _cameraInitialized = true);
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      if (!mounted) return;
      setState(() {
        _cameraError =
            "Could not access camera.\nPlease check browser permissions and refresh.";
      });
    }
  }

  void _stopCameraStream() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream = null;

    _videoElement?.remove();
    _videoElement?.srcObject = null;
    _videoElement = null;

    if (!mounted) return;
    setState(() => _cameraInitialized = false);
  }

  Future<void> _switchCamera() async {
    if (_videoDevices.length < 2) return;

    _stopCameraStream();

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _videoDevices.length;
    });

    await _initCamera();
  }

  Future<void> _capturePhoto() async {
    if (_videoElement == null || !_cameraInitialized) return;

    final canvas = html.CanvasElement(
      width: _videoElement!.videoWidth,
      height: _videoElement!.videoHeight,
    );
    canvas.context2D.drawImage(_videoElement!, 0, 0);
    final blob = await canvas.toBlob('image/png');
    if (!mounted) return;

    final previewUrl = html.Url.createObjectUrlFromBlob(blob);

    final imageElement = html.ImageElement(src: previewUrl)
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    _cameraContainerElement.children.add(imageElement);

    setState(() {
      _capturedBlob = blob;
      _capturedBlobType = 'image/png';
      _previewUrl = previewUrl;
    });
  }

  void _startRecording() {
    if (_localStream == null) return;

    _recordedBlobs.clear();
    _recorder = html.MediaRecorder(_localStream!, {'mimeType': 'video/webm'});

    _recorder!.addEventListener('dataavailable', (html.Event event) {
      final blobEvent = event as html.BlobEvent;
      if (blobEvent.data != null) {
        _recordedBlobs.add(blobEvent.data!);
      }
    });

    _recorder!.start();
    setState(() => _isRecording = true);

    Future.delayed(const Duration(seconds: 10), () {
      if (_isRecording) _stopRecording();
    });
  }

  Future<void> _stopRecording() async {
    if (_recorder == null) return;

    final completer = Completer<html.Blob?>();

    _recorder!.addEventListener('stop', (html.Event event) {
      final blob = html.Blob(_recordedBlobs, 'video/webm');
      completer.complete(blob);
    });

    _recorder!.stop();
    setState(() => _isRecording = false);

    final blob = await completer.future;
    if (blob != null) {
      final file = html.File([blob], 'recording.webm', {'type': 'video/webm'});
      widget.onMediaCaptured(file);
    }
  }

  void _closeCameraView() {
    if (!mounted) return;
    _stopCameraStream();
    _resetCaptureState();

    setState(() {
      _showCamera = false;
    });
  }

  void _confirmCapture() {
    if (_capturedBlob == null) return;

    final fileName = _capturedBlobType!.startsWith('image')
        ? 'capture.png'
        : 'capture.webm';

    final file = html.File(
      [_capturedBlob!],
      fileName,
      {'type': _capturedBlobType},
    );

    widget.onMediaCaptured(file);

    _stopCameraStream();
    _resetCaptureState();

    setState(() {
      _showCamera = false;
      _cameraInitialized = false;
    });
  }

  void _retake() {
    _resetCaptureState();
    _cameraContainerElement.children.removeWhere(
      (child) =>
          child is html.ImageElement ||
          (child is html.VideoElement && child != _videoElement),
    );
  }

  void _toggleCamera() {
    if (_showCamera) {
      _closeCameraView();
    } else {
      if (!mounted) return;
      setState(() {
        _showCamera = true;
      });
      _initCamera();
    }
  }

  @override
  void dispose() {
    _stopCameraStream();
    _resetCaptureState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_showCamera)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Open Camera"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                foregroundColor: Colors.indigo,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.indigo.shade200),
                ),
              ),
            ),
          ),
        if (_showCamera) ...[
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.indigo.shade200),
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Builder(
                builder: (context) {
                  if (_cameraError != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _cameraError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  if (!_isInPreviewMode && !_cameraInitialized) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            "Initializing camera...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }
                  return HtmlElementView(
                    key: _cameraViewKey,
                    viewType: _viewType,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_isInPreviewMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _retake,
                  icon: const Icon(Icons.replay),
                  label: const Text("Retake"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.orange.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _confirmCapture,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade800,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _cameraInitialized && !_isRecording
                          ? _capturePhoto
                          : null,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text("Photo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _cameraInitialized && !_isRecording
                          ? _startRecording
                          : null,
                      icon: const Icon(Icons.videocam, size: 20),
                      label: const Text("Record"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isRecording ? _stopRecording : null,
                      icon: const Icon(Icons.stop, size: 20),
                      label: const Text("Stop"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_videoDevices.length > 1)
                  ElevatedButton.icon(
                    onPressed: _switchCamera,
                    icon: const Icon(Icons.switch_camera),
                    label: const Text("Switch Camera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _toggleCamera,
              icon: const Icon(Icons.close, size: 18),
              label: const Text("Close Camera"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
