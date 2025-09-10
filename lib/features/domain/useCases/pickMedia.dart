import 'dart:html' as html;
import 'package:feedbackdemo/features/data/source/pickMediaSource.dart';

class PickMedia {
  final MediaRemoteDataSource dataSource;

  PickMedia(this.dataSource);

  Future<html.File?> call({bool allowVideo = false}) async {
    return await dataSource.pickMedia(allowVideo: allowVideo);
  }
}
