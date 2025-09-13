import 'package:feedbackdemo/features/submitFeedback/data/repositoryImplementation/repositoryImplementation.dart';
import 'package:feedbackdemo/features/submitFeedback/data/source/feedbackRemoteDataSource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final feedbackRemoteDataSourceProvider = Provider(
  (ref) => FeedbackRemoteDataSource(
    client: http.Client(),
    baseUrl: 'http://localhost:5005', // your Node.js backend
  ),
);

final feedbackRepositoryProvider = Provider(
  (ref) => FeedbackRepositoryImpl(
    remoteDataSource: ref.read(feedbackRemoteDataSourceProvider),
  ),
);
final feedbackProvider = StateProvider<String?>((ref) => null);
