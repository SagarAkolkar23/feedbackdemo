import 'package:feedbackdemo/features/getEntity/entityScreen.dart';
import 'package:feedbackdemo/features/presentation/screens/feedbackScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/EntityList',
    routes: [
      // ✅ Updated to accept entityId (int) and tags (list of strings)
      GoRoute(
        path: '/feedbackform/:entityId/:tags',
        builder: (context, state) {
          final entityIdStr = state.pathParameters['entityId'];
          final tagsString = state.pathParameters['tags'] ?? '';

          final entityId = int.tryParse(entityIdStr ?? '0') ?? 0;

          // Decode and split tags safely
          final decodedTags = Uri.decodeComponent(tagsString);
          final tags = decodedTags.isEmpty
              ? <String>[]
              : decodedTags.split(',').where((t) => t.isNotEmpty).toList();

          return FeedbackFormScreen(entityId: entityId, tags: tags);
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
