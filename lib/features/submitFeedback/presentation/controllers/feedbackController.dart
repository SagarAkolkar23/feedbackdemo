import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html; // for web file info

import '../../domain/entity/feedbackEntity.dart';
import '../providers/feedbackProvider.dart';
import '../../data/repositoryImplementation/repositoryImplementation.dart';

class FeedbackController extends StateNotifier<AsyncValue<FeedbackEntity?>> {
  final Ref ref;

  FeedbackController(this.ref) : super(const AsyncValue.data(null));

  Future<void> submitFeedback(FeedbackEntity entity, dynamic file) async {
    state = const AsyncValue.loading();
    try {
      // 🔎 Debug logging for file
      if (file != null) {
        if (kIsWeb && file is html.File) {
          print('📹 Web file selected: ${file.name}');
          print('   Type: ${file.type}');
          print('   Size: ${file.size} bytes');
        } else if (file is File) {
          print('📱 Mobile/desktop file selected: ${file.path}');
          print('   Length: ${await file.length()} bytes');
        } else {
          print('⚠️ Unknown file type: ${file.runtimeType}');
        }
      } else {
        print('ℹ️ No file attached');
      }

      final repo = ref.read(feedbackRepositoryProvider);
      final result = await repo.submitFeedback(entity, file);
      state = AsyncValue.data(result);
    } catch (e, st) {
      print('❌ Error while submitting feedback: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final feedbackControllerProvider = StateNotifierProvider<
    FeedbackController, AsyncValue<FeedbackEntity?>>(
  (ref) => FeedbackController(ref),
);
