import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';

class TrashView extends StatelessWidget {
  final String searchQuery;
  
  const TrashView({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final FirebaseAuthService authService = FirebaseAuthService();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Please login to view notes'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.streamCollection(
        collectionPath: 'notes',
        orderByField: 'updatedAt',
        descending: true,
        whereConditions: {'userId': userId},
      ).map((notes) {
        // Filter for deleted notes and search query
        return notes.where((note) {
          final isDeleted = note['isDeleted'] == true;
          
          // Search filter
          bool matchesSearch = true;
          if (searchQuery.isNotEmpty) {
            final title = (note['title'] ?? '').toString().toLowerCase();
            final content = (note['content'] ?? '').toString().toLowerCase();
            matchesSearch = title.contains(searchQuery) || content.contains(searchQuery);
          }
          
          return isDeleted && matchesSearch;
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trashedNotes = snapshot.data ?? [];

        if (trashedNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Trash is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trashedNotes.length,
          itemBuilder: (context, index) {
            final note = trashedNotes[index];
            final updatedAt = DateTime.tryParse(note['updatedAt'] ?? '');
            final formattedDate = updatedAt != null
                ? '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}'
                : 'Unknown date';

            return _TrashNoteCard(
              title: note['title'] ?? 'Untitled',
              description: 'Deleted on $formattedDate',
              onRestore: () async {
                await firestoreService.updateDocument(
                  collectionPath: 'notes',
                  documentId: note['id'],
                  data: {'isDeleted': false},
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note restored')),
                );
              },
              onPermanentDelete: () async {
                // Show confirmation dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Permanently'),
                    content: const Text('This note will be deleted permanently. This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await firestoreService.deleteDocument(
                    collectionPath: 'notes',
                    documentId: note['id'],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note permanently deleted')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class _TrashNoteCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  const _TrashNoteCard({
    required this.title,
    required this.description,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(description, style: const TextStyle(color: Colors.black54)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.blue),
              onPressed: onRestore,
              tooltip: 'Restore',
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: onPermanentDelete,
              tooltip: 'Delete permanently',
            ),
          ],
        ),
      ),
    );
  }
}
