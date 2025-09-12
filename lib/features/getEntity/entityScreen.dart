import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:feedbackdemo/features/getEntity/model.dart';
import 'package:feedbackdemo/features/getEntity/apiService.dart';

class EntityListScreen extends StatefulWidget {
  const EntityListScreen({super.key});

  @override
  State<EntityListScreen> createState() => _EntityListScreenState();
}

class _EntityListScreenState extends State<EntityListScreen> {
  late Future<List<Entity>> _entities;

  @override
  void initState() {
    super.initState();
    _entities = ApiService.getAllEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entities')),
      body: FutureBuilder<List<Entity>>(
        future: _entities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No entities found.'));
          }

          final entities = snapshot.data!;

          return ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              final entity = entities[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(entity.handle),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      try {
                        // ✅ Fetch full entity with tags
                        final entityFull = await ApiService.getEntityFull(
                          entity.id,
                          entity.handle,
                        );

                        final tags = entityFull.tags
                            .map((t) => t.name)
                            .toList();

                        // ✅ Encode tags safely for URL
                        final encodedTags = Uri.encodeComponent(tags.join(","));

                        // ✅ Navigate with entityId + tags in URL
                        context.go('/feedbackform/${entity.id}/$encodedTags');
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text('Fetch Details'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
