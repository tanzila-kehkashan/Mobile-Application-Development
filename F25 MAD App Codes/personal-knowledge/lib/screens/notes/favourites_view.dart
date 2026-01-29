import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../edit_note_screen.dart';
import '../view_note_screen.dart';

class FavouritesView extends StatelessWidget {
  final String searchQuery;
  
  const FavouritesView({Key? key, this.searchQuery = ''}) : super(key: key);

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
        orderByField: 'createdAt',
        descending: true,
        whereConditions: {'userId': userId},
      ).map((notes) {
        // Filter for favourites, not deleted, not hidden, and search query
        return notes.where((note) {
          final isFavourite = note['isFavourite'] == true;
          final isNotDeleted = note['isDeleted'] == false || note['isDeleted'] == null;
          final isNotHidden = note['isHidden'] == false || note['isHidden'] == null;
          
          // Search filter
          bool matchesSearch = true;
          if (searchQuery.isNotEmpty) {
            final title = (note['title'] ?? '').toString().toLowerCase();
            final content = (note['content'] ?? '').toString().toLowerCase();
            matchesSearch = title.contains(searchQuery) || content.contains(searchQuery);
          }
          
          return isFavourite && isNotDeleted && isNotHidden && matchesSearch;
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final favouriteNotes = snapshot.data ?? [];

        if (favouriteNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No favourite notes',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favouriteNotes.length,
          itemBuilder: (context, index) {
            final note = favouriteNotes[index];
            final createdAt = DateTime.tryParse(note['createdAt'] ?? '');
            final formattedDate = createdAt != null
                ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                : 'Unknown date';

            return _FavouriteNoteCard(
              note: note,
              title: note['title'] ?? 'Untitled',
              description: formattedDate,
              onTap: () {
                // Tap to VIEW note
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ViewNoteScreen(note: note)),
                );
              },
              onEdit: () {
                // Edit button to EDIT note
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
                );
              },
              onRemoveFavourite: () async {
                await firestoreService.updateDocument(
                  collectionPath: 'notes',
                  documentId: note['id'],
                  data: {'isFavourite': false},
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FavouriteNoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final String title;
  final String description;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onRemoveFavourite;

  const _FavouriteNoteCard({
    required this.note,
    required this.title,
    required this.description,
    required this.onTap,
    required this.onEdit,
    required this.onRemoveFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,  // Tap to open note
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.star, color: Colors.amber, size: 28),
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
              icon: const Icon(Icons.edit, color: Colors.amber, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit note',
            ),
            IconButton(
              icon: const Icon(Icons.star_border, color: Colors.amber),
              onPressed: onRemoveFavourite,
              tooltip: 'Remove from favourites',
            ),
          ],
        ),
      ),
    );
  }
}
