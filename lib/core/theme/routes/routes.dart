import 'package:feedbackdemo/features/getEntity/entityScreen.dart';
import 'package:feedbackdemo/features/getEntity/entityDetailsModel.dart';
import 'package:feedbackdemo/features/submitFeedback/presentation/screens/feedbackScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/EntityList',
    routes: [
      // ✅ Updated to accept entityId (int), tags (list of strings), and extra data
      GoRoute(
        path: '/feedbackform/:entityId/:tags',
        builder: (context, state) {
          // Get params from the path
          final entityIdStr = state.pathParameters['entityId'];
          final tagsString = state.pathParameters['tags'] ?? '';

          // Convert entityId safely
          final entityId = int.tryParse(entityIdStr ?? '0') ?? 0;

          // Decode and split tags safely
          final decodedTags = Uri.decodeComponent(tagsString);
          final tags = decodedTags.isEmpty
              ? <String>[]
              : decodedTags.split(',').where((t) => t.isNotEmpty).toList();

          // ✅ Get the full entity details from extra (if passed)
          final extra = state.extra;
          EntityDetails? entityDetails;
          if (extra is EntityDetails) {
            entityDetails = extra;
          }

          return FeedbackFormScreen(
            entityId: entityId,
            tags: tags,
            entityDetails: entityDetails, // 🔑 Available immediately
          );
        },
      ),
      GoRoute(
        path: '/EntityList',
        builder: (context, state) => const EntityListScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Route not found 🚨"))),
  );
}
