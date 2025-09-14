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
    _loadEntities();
  }

  void _loadEntities() {
    _entities = ApiService.getAllEntities();
  }

  Future<void> _refreshEntities() async {
    setState(() {
      _loadEntities();
    });
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No entities found.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/registerentity'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Entity'),
                  ),
                ],
              ),
            );
          }

          final entities = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshEntities,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: entities.length,
              itemBuilder: (context, index) {
                final entity = entities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(entity.handle),
                    trailing: ElevatedButton(
                      onPressed: () {
                        context.go(
                          '/feedbackform/${entity.id}/${Uri.encodeComponent(entity.handle)}',
                        );
                      },
                      child: const Text('Open Feedback'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to register entity screen
          context.go('/registerentity');
          // Optional: reload entities after returning
          await _refreshEntities();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Entity"),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
