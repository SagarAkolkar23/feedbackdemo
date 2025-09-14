import 'package:feedbackdemo/features/details/presentation/screen/companyDetailsScreen.dart';
import 'package:feedbackdemo/features/otp/presentation/screen/getOtpScreen.dart';
import 'package:feedbackdemo/features/otp/presentation/screen/verifyOtpScreen.dart';
import 'package:feedbackdemo/features/tags/presentation/screen/tagScreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:feedbackdemo/features/getEntity/entityScreen.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/screens/feedbackScreen.dart';


class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/EntityList', // ✅ starting point
    routes: [
      // -------------------------------
      // Feedback Demo Routes
      // -------------------------------
      GoRoute(
        path: '/EntityList',
        builder: (context, state) => const EntityListScreen(),
      ),
      GoRoute(
        path: '/feedbackform/:entityId/:entityHandle',
        builder: (context, state) {
          final entityIdStr = state.pathParameters['entityId'];
          final entityHandle = state.pathParameters['entityHandle'] ?? '';
          final entityId = int.tryParse(entityIdStr ?? '0') ?? 0;

          return FeedbackFormScreen(
            entityId: entityId,
            entityHandle: entityHandle,
          );
        },
      ),

      // -------------------------------
      // Entity Routes
      // -------------------------------
      GoRoute(
        path: '/registerentity',
        builder: (context, state) => CompanyDetailsPage(),
      ),
      GoRoute(
        path: '/tagselection',
        builder: (context, state) => TagSelectionPage(),
      ),
      GoRoute(path: '/get-otp', builder: (context, state) => GetOtpScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => VerifyOtpScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Route not found 🚨"))),
  );
}
