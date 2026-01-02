import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_notes/models/note.dart';
import 'package:uuid/uuid.dart';
import 'notification_service.dart';

class NoteService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationService _notificationService = NotificationService();
  final String? _uid;

  late final CollectionReference _notesCollection;

  NoteService(this._uid) {
    if (_uid != null) {
      _notesCollection = _firestore.collection('users').doc(_uid).collection('notes');
    }
  }

  Stream<List<Note>> getNotes() {
    if (_uid == null) return Stream.value([]);
    return _notesCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    });
  }

  Future<Note?> getNoteById(String noteId) async {
    if (_uid == null) return null;
    final doc = await _notesCollection.doc(noteId).get();
    if (doc.exists) {
      return Note.fromFirestore(doc);
    }
    return null;
  }

  Future<void> addNote(String title, String content, String tag, {String? imagePath, String? extractedText}) async {
    if (_uid == null) return;
    String? imageUrl;
    if (imagePath != null) {
      final imageFile = File(imagePath);
      final imageId = const Uuid().v4();
      final ref = _storage.ref().child('note_images').child(_uid!).child('$imageId.jpg');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    final newNote = Note(
      id: const Uuid().v4(),
      userId: _uid!,
      title: title,
      content: content,
      tag: tag,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
      extractedText: extractedText,
    );

    await _notesCollection.doc(newNote.id).set(newNote.toFirestore());
    
    // Create notification for new note
    await _notificationService.addNotification(
      title: 'Note Created',
      description: 'You created "$title"',
      iconType: 'document',
    );
    
    notifyListeners();
  }

  Future<void> updateNote(Note note, {String? imagePath}) async {
    if (_uid == null) return;
    String? imageUrl = note.imageUrl;
    if (imagePath != null) {
      final imageFile = File(imagePath);
      final imageId = const Uuid().v4();
      final ref = _storage.ref().child('note_images').child(_uid!).child('$imageId.jpg');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    final updatedNote = Note(
      id: note.id,
      userId: note.userId,
      title: note.title,
      content: note.content,
      tag: note.tag,
      createdAt: note.createdAt,
      lastEdited: DateTime.now(),
      imageUrl: imageUrl,
      extractedText: note.extractedText,
    );

    await _notesCollection.doc(note.id).update(updatedNote.toFirestore());
    
    // Create notification for updated note
    await _notificationService.addNotification(
      title: 'Note Updated',
      description: 'You updated "${note.title}"',
      iconType: 'document',
    );
    
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    if (_uid == null) return;
    
    // Get note title before deleting
    final note = await getNoteById(noteId);
    final noteTitle = note?.title ?? 'Unknown';
    
    await _notesCollection.doc(noteId).delete();
    
    // Create notification for deleted note
    await _notificationService.addNotification(
      title: 'Note Deleted',
      description: 'You deleted "$noteTitle"',
      iconType: 'document',
    );
    
    notifyListeners();
  }

  Future<List<Note>> searchNotes(String query) async {
    if (_uid == null) return [];

    final snapshot = await _notesCollection.get();
    final notes = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();

    if (query.isEmpty) {
      return notes;
    }

    final lowerCaseQuery = query.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(lowerCaseQuery) ||
          note.content.toLowerCase().contains(lowerCaseQuery) ||
          note.tag.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }
}
