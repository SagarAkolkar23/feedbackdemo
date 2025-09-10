import 'package:feedbackdemo/features/presentation/screens/feedbackScreen.dart';
import 'package:flutter/material.dart';

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback Demo (Web)',
      debugShowCheckedModeBanner: false,
      home: FeedbackFormScreen(),
    );
  }
}
