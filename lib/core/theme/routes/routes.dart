import 'package:feedbackdemo/features/getEntity/entityScreen.dart';
import 'package:feedbackdemo/features/getEntity/entityDetailsModel.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/screens/feedbackScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/EntityList',
    routes: [
      // ✅ Only entityId & entityHandle in path
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
      GoRoute(
        path: '/',
        builder: (context, state) => const EntityListScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Route not found 🚨"))),
  );
}
