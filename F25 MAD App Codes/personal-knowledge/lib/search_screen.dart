import 'package:flutter/material.dart';
import 'services/firestore_service.dart';
import 'services/firebase_auth_service.dart';
import 'screens/view_note_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _controller.addListener(_onSearchChanged);
  }

  Future<void> _loadNotes() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Listen to notes stream
    _firestoreService.streamCollection(
      collectionPath: 'notes',
      orderByField: 'createdAt',
      descending: true,
    ).listen((notes) {
      final userNotes = notes.where((note) {
        return note['userId'] == userId &&
               (note['isDeleted'] == false || note['isDeleted'] == null) &&
               (note['isHidden'] == false || note['isHidden'] == null);  // Exclude hidden notes
      }).toList();

      setState(() {
        _allNotes = userNotes;
        _filteredNotes = userNotes;
        _isLoading = false;
      });

      // Re-apply search if there's a query
      if (_controller.text.isNotEmpty) {
        _onSearchChanged();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = List.from(_allNotes);
      } else {
        _filteredNotes = _allNotes.where((note) {
          final title = (note['title'] ?? '').toString().toLowerCase();
          final content = (note['content'] ?? '').toString().toLowerCase();
          return title.contains(query) || content.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Search TextField
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search notes by title or content...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results count
            if (_controller.text.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredNotes.length} result${_filteredNotes.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (_controller.text.isNotEmpty) const SizedBox(height: 8),

            // Search Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : userId == null
                      ? const Center(
                          child: Text(
                            'Please login to search notes',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        )
                      : _filteredNotes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _controller.text.isEmpty
                                        ? Icons.search
                                        : Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _controller.text.isEmpty
                                        ? 'Start typing to search your notes'
                                        : 'No notes found',
                                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredNotes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final note = _filteredNotes[index];
                                final title = note['title'] ?? 'Untitled';
                                final createdAt = DateTime.tryParse(note['createdAt'] ?? '');
                                final formattedDate = createdAt != null
                                    ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                                    : 'Unknown date';
                                final isFavourite = note['isFavourite'] == true;

                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  tileColor: Colors.white,
                                  leading: Icon(
                                    isFavourite ? Icons.star : Icons.note,
                                    color: isFavourite ? Colors.amber : const Color(0xFF007AFF),
                                  ),
                                  title: Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(formattedDate),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    // Tap to VIEW note
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ViewNoteScreen(note: note),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
