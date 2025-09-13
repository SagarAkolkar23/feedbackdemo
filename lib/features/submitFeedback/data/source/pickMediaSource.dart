import 'dart:html' as html;

class MediaRemoteDataSource {
  Future<html.File?> pickMedia({bool allowVideo = false}) async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = allowVideo ? 'image/*,video/*' : 'image/*';
    uploadInput.click();

    await uploadInput.onChange.first;
    final file = uploadInput.files?.first;
    return file; 
  }
}
