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
      appBar: AppBar(
        title: const Text('Entities'),
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // your desired color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                context.go('/registerentity');
                _refreshEntities();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Entity'),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Entity>>(
        future: _entities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No entities found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final entities = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshEntities,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entities.length,
              itemBuilder: (context, index) {
                final entity = entities[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    title: Text(
                      entity.handle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Entity ID: ${entity.id}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
    );
  }
}
