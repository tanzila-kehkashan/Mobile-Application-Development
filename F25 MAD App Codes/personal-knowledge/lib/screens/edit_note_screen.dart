import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/analytics_service.dart';

// Delta is part of flutter_quill
import 'package:flutter_quill/quill_delta.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late QuillController _contentController;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AnalyticsService _analyticsService = AnalyticsService();

  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing note data
    _titleController = TextEditingController(text: widget.note['title'] ?? '');
    
    // Load existing content from JSON
    try {
      final contentJson = widget.note['content'];
      if (contentJson != null && contentJson.isNotEmpty) {
        final delta = Delta.fromJson(jsonDecode(contentJson) as List);
        _contentController = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        _contentController = QuillController.basic();
      }
    } catch (e) {
      _contentController = QuillController.basic();
    }
    
    // Parse selected date
    _selectedDate = DateTime.tryParse(widget.note['selectedDate'] ?? '') ?? DateTime.now();
  }

  Future<void> _updateNote() async {
    final title = _titleController.text.trim();
    final userId = _authService.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to update notes')),
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

      // Update in Firestore
      await _firestoreService.updateDocument(
        collectionPath: 'notes',
        documentId: widget.note['id'],
        data: {
          'title': title,
          'content': contentJson,
          'selectedDate': _selectedDate.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Log analytics
      await _analyticsService.logNoteEdited(
        noteId: widget.note['id'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update note: $e'),
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
          "Edit Note",
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
                  onPressed: _updateNote,
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
