import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/analytics_service.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({Key? key}) : super(key: key);

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _contentController = QuillController.basic();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AnalyticsService _analyticsService = AnalyticsService();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final userId = _authService.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save notes')),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note title')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Convert Quill content to JSON
      final contentJson = jsonEncode(_contentController.document.toDelta().toJson());

      // Save to Firestore
      await _firestoreService.addDocument(
        collectionPath: 'notes',
        data: {
          'userId': userId,
          'title': title,
          'content': contentJson,
          'selectedDate': _selectedDate.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'isFavourite': false,
          'isHidden': false,
          'isDeleted': false,
        },
      );

      // Log analytics
      await _analyticsService.logNoteCreated(
        noteType: 'rich_text',
        noteLength: title.length,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Create Note",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Date Picker
          IconButton(
            icon: const Icon(Icons.calendar_today, color: blue),
            onPressed: _isSaving ? null : () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          // Save Button
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check, color: blue, size: 28),
                  onPressed: _saveNote,
                ),
        ],
      ),
      body: Column(
        children: [
          // Date & Title Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  enabled: !_isSaving,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: "Note Title",
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Quill Toolbar
          QuillSimpleToolbar(
            controller: _contentController,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showSearchButton: false,
              showInlineCode: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),

          const Divider(height: 1),

          // Quill Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: QuillEditor.basic(
                controller: _contentController,
                config: const QuillEditorConfig(
                  placeholder: 'Start writing your note...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}