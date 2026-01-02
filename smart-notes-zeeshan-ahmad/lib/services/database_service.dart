import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/note.dart';
class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final String? _uid;

  DatabaseService(this._uid);

  // Reference to the database root
  DatabaseReference get _databaseRef => _database.ref();

  // Get current user ID
  String? get _currentUserId => _uid ?? _auth.currentUser?.uid;

  // Add a note to Realtime Database
  Future<void> addNoteToDatabase(Note note) async {
    if (_currentUserId == null) return;

    final noteRef = _databaseRef.child('users').child(_currentUserId!).child('notes').child(note.id);
    await noteRef.set(note.toFirestore());
  }

  // Update a note in Realtime Database
  Future<void> updateNoteInDatabase(Note note) async {
    if (_currentUserId == null) return;

    final noteRef = _databaseRef.child('users').child(_currentUserId!).child('notes').child(note.id);
    await noteRef.update(note.toFirestore());
  }

  // Delete a note from Realtime Database
  Future<void> deleteNoteFromDatabase(String noteId) async {
    if (_currentUserId == null) return;

    final noteRef = _databaseRef.child('users').child(_currentUserId!).child('notes').child(noteId);
    await noteRef.remove();
  }

  // Get a specific note from Realtime Database
  Future<DataSnapshot> getNoteFromDatabase(String noteId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final noteRef = _databaseRef.child('users').child(_currentUserId!).child('notes').child(noteId);
    return await noteRef.get();
  }

  // Get all notes for the current user
  Future<DataSnapshot> getAllNotesFromDatabase() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final notesRef = _databaseRef.child('users').child(_currentUserId!).child('notes');
    return await notesRef.get();
  }

  // Listen for real-time updates to notes
  Stream<DatabaseEvent> notesStream() {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final notesRef = _databaseRef.child('users').child(_currentUserId!).child('notes');
    return notesRef.onValue;
  }

  // Search notes by title or content
  Future<List<Note>> searchNotes(String query) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final notesRef = _databaseRef.child('users').child(_currentUserId!).child('notes');
    final snapshot = await notesRef.get();
    
    List<Note> results = [];
    
    if (snapshot.exists) {
      final notesData = snapshot.value as Map<dynamic, dynamic>? ?? {};
      
      notesData.forEach((key, value) {
        if (value is Map) {
          final noteData = Map<String, dynamic>.from(value);
          final note = Note.fromMap(noteData, key.toString());
          
          // Check if query matches title or content
          if (note.title.toLowerCase().contains(query.toLowerCase()) || 
              note.content.toLowerCase().contains(query.toLowerCase())) {
            results.add(note);
          }
        }
      });
    }
    
    return results;
  }
}
