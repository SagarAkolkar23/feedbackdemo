import 'package:feedbackdemo/core/theme/routes/routes.dart';
import 'package:flutter/material.dart';

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Feedback Demo (Web)',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}
