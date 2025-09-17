import 'package:feedbackdemo/features/submitFeedback/data/repositoryImplementation/repositoryImplementation.dart';
import 'package:feedbackdemo/features/submitFeedback/data/source/feedbackRemoteDataSource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final feedbackRemoteDataSourceProvider = Provider(
  (ref) => FeedbackRemoteDataSource(
    client: http.Client(),
    baseUrl: 'https://select-original-compaq-drums.trycloudflare.com', // your Node.js backend
  ),
);

final feedbackRepositoryProvider = Provider(
  (ref) => FeedbackRepositoryImpl(
    remoteDataSource: ref.read(feedbackRemoteDataSourceProvider),
  ),
);
final feedbackProvider = StateProvider<String?>((ref) => null);
