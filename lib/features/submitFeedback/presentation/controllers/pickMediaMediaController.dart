import 'package:feedbackdemo/features/submitFeedback/domain/useCases/pickMedia.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;

final mediaControllerProvider =
    StateNotifierProvider<MediaController, html.File?>((ref) {
      final useCase = ref.read(pickMediaProvider);
      return MediaController(useCase);
    });

final pickMediaProvider = Provider<PickMedia>((ref) {
  throw UnimplementedError('Inject MediaRemoteDataSourceImpl here');
});

class MediaController extends StateNotifier<html.File?> {
  final PickMedia pickMedia;

  MediaController(this.pickMedia) : super(null);

  
  Future<void> pick({
    bool allowVideo = false,
    String captureMode = 'device',
  }) async {
    html.File? file;

    if (captureMode == 'device') {
      file = await pickMedia(allowVideo: allowVideo);
    } else {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = allowVideo ? 'image/*,video/*' : 'image/*';

      if (captureMode == 'cameraPhoto') {
        uploadInput.setAttribute('capture', 'environment'); 
      } else if (captureMode == 'cameraVideo') {
        uploadInput.setAttribute('capture', 'user'); 
      }

      uploadInput.click();
      await uploadInput.onChange.first;
      file = uploadInput.files?.first;

    }

    if (file != null) {
      state = file; 
    }
  }

  void removeMedia() {
    state = null;
  }
}
