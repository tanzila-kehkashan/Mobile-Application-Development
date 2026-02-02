import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'edit_note_screen.dart';

class ViewNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const ViewNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<ViewNoteScreen> createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    
    // Load existing note content
    try {
      final contentJson = widget.note['content'] as String;
      final doc = Document.fromJson(jsonDecode(contentJson));
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _controller.readOnly = true;  // Set read-only after creation
    } catch (e) {
      // If content is invalid, create empty document
      _controller = QuillController.basic();
      _controller.readOnly = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(widget.note['createdAt'] ?? '');
    final formattedDate = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : 'Unknown date';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'View Note',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Edit button in app bar
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF007AFF)),
            onPressed: () {
              // Navigate to edit screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => EditNoteScreen(note: widget.note),
                ),
              );
            },
            tooltip: 'Edit note',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (read-only)
              Text(
                widget.note['title'] ?? 'Untitled',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Date
              Text(
                'Created: $formattedDate',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Content (read-only)
              Expanded(
                child: QuillEditor.basic(
                  controller: _controller,
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating action button to edit
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EditNoteScreen(note: widget.note),
            ),
          );
        },
        backgroundColor: const Color(0xFF007AFF),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Edit', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
