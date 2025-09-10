import 'package:feedbackdemo/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- missing import


void main() {
  runApp(const ProviderScope(child: FeedbackApp()));
}
