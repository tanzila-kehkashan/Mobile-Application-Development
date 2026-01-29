import 'package:flutter/material.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  _AddQuizScreenState createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  // Sample data to display in the list
  final List<Map<String, String>> _quizzes = [
    {'title': 'Flutter Quiz', 'subtitle': 'Dart basics'},
    {'title': 'Computer Science', 'subtitle': 'General knowledge'},
  ];

  @override
  Widget build(BuildContext context) {
    // Wrapping in a Theme to ensure the dark style matches your specific request
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2c2c2c),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3a3a3a),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Navigate back to Admin Dashboard
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'ADMIN DASHBOARD',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: ListView.builder(
            itemCount: _quizzes.length,
            itemBuilder: (context, index) {
              return _buildQuizCard(_quizzes[index]['title']!);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddQuizDialog(context);
          },
          backgroundColor: const Color(0xFF26E3BA), // Teal/Cyan color
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  // Widget for the list items (dark grey cards)
  Widget _buildQuizCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF3e3e3e), // Card color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.book, color: Colors.white, size: 28),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }

  // Function to show the "Add Quiz" dialog
  void _showAddQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          backgroundColor: const Color(0xFFE0E0E0), // Light grey background
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Add Quiz",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                // Category Name Input
                const TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter the category name",
                    hintStyle: TextStyle(color: Colors.black54),
                    // Changing border color to black/grey so it's visible on light background
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Subtitle Input
                const TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter the Subtitle",
                    hintStyle: TextStyle(color: Colors.black54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton("cancel", () {
                      Navigator.pop(context);
                    }),
                    _buildDialogButton("create", () {
                      // Add creation logic here
                      print("Create Quiz Category pressed");
                      Navigator.pop(context);
                    }),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper for the teal buttons in the dialog
  Widget _buildDialogButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF26E3BA), // Teal/Cyan color
        foregroundColor: Colors.black, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}