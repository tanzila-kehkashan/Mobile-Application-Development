import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EventEditScreen extends StatefulWidget {
  final String initialText;

  const EventEditScreen({Key? key, required this.initialText}) : super(key: key);

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  late QuillController _controller;
  final TextEditingController _titleController = TextEditingController(text: "Event Note");

  @override
  void initState() {
    super.initState();
    // 1. FIXED: Initializing document without 'Delta' class to avoid errors
    _controller = QuillController(
      document: Document()..insert(0, widget.initialText + '\n'),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
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
        actions: [
          TextButton(
            onPressed: () {
              // Return the edited text as plain text
              String editedText = _controller.document.toPlainText();
              Navigator.pop(context, editedText);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  hintText: 'Page Title',
                  border: InputBorder.none
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          const Divider(height: 1),

          // 2. FIXED: Updated Toolbar Config
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showSearchButton: false,
              showInlineCode: false,
            ),
          ),

          const Divider(height: 1),

          // 3. FIXED: Updated Editor Config
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: QuillEditor.basic(
                controller: _controller,
                config: const QuillEditorConfig(
                  placeholder: 'Write your details here...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}