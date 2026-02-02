import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../edit_note_screen.dart';
import '../view_note_screen.dart';

class AllNotesView extends StatelessWidget {
  final String searchQuery;
  
  const AllNotesView({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final FirebaseAuthService authService = FirebaseAuthService();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text('Please login to view notes'),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.streamCollection(
        collectionPath: 'notes',
        orderByField: 'createdAt',
        descending: true,
        whereConditions: {'userId': userId},
      ).map((notes) {
        // Filter for not deleted, not hidden, and search query
        return notes.where((note) {
          final isNotDeleted = note['isDeleted'] == false || note['isDeleted'] == null;
          final isNotHidden = note['isHidden'] == false || note['isHidden'] == null;
          
          // Search filter
          bool matchesSearch = true;
          if (searchQuery.isNotEmpty) {
            final title = (note['title'] ?? '').toString().toLowerCase();
            final content = (note['content'] ?? '').toString().toLowerCase();
            matchesSearch = title.contains(searchQuery) || content.contains(searchQuery);
          }
          
          return isNotDeleted && isNotHidden && matchesSearch;
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error.toString();
          if (error.contains('permission-denied') || error.contains('PERMISSION_DENIED')) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 60, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text('Access Denied', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Please ensure you have deployed the security rules in Firebase Console.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Force rebuild
                        (context as Element).markNeedsBuild();
                      },
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userNotes = snapshot.data ?? [];

        if (userNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notes yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the Create button to add your first note',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userNotes.length,
          itemBuilder: (context, index) {
            final note = userNotes[index];
            final createdAt = DateTime.tryParse(note['createdAt'] ?? '');
            final formattedDate = createdAt != null
                ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                : 'Unknown date';
            final isFavourite = note['isFavourite'] == true;

            return _NoteCard(
              title: note['title'] ?? 'Untitled',
              description: formattedDate,
              isFavourite: isFavourite,
              onTap: () {
                // Tap to VIEW note (read-only)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewNoteScreen(note: note),
                  ),
                );
              },
              onEdit: () {
                // Edit button to EDIT note
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditNoteScreen(note: note),
                  ),
                );
              },
              onMenuAction: (action) async {
                switch (action) {
                  case 'delete':
                    await firestoreService.updateDocument(
                      collectionPath: 'notes',
                      documentId: note['id'],
                      data: {'isDeleted': true},
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note moved to trash')),
                    );
                    break;
                  
                  case 'favourite':
                    await firestoreService.updateDocument(
                      collectionPath: 'notes',
                      documentId: note['id'],
                      data: {'isFavourite': !isFavourite},
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavourite 
                            ? 'Removed from favourites' 
                            : 'Added to favourites'
                        ),
                      ),
                    );
                    break;
                  
                  case 'hide':
                    await firestoreService.updateDocument(
                      collectionPath: 'notes',
                      documentId: note['id'],
                      data: {'isHidden': true},
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note hidden')),
                    );
                    break;
                }
              },
            );
          },
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final Function(String) onMenuAction;

  const _NoteCard({
    required this.title,
    required this.description,
    required this.isFavourite,
    required this.onTap,
    required this.onEdit,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF007AFF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,  // Tap to view note
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: isFavourite 
          ? const Icon(Icons.star, color: Colors.amber, size: 28)
          : const Icon(Icons.note, color: Color(0xFF007AFF), size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF007AFF), size: 20),
              onPressed: onEdit,
              tooltip: 'Edit note',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: onMenuAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'favourite',
                  child: Row(
                    children: [
                      Icon(
                        isFavourite ? Icons.star_border : Icons.star,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(isFavourite ? 'Remove from Favourites' : 'Add to Favourites'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'hide',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_off, size: 20),
                      SizedBox(width: 12),
                      Text('Hide Note'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Move to Trash', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
