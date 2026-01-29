import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);
  static const Color blue = Color(0xFF007AFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('FAQs', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            color: blue,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.help_outline, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text('How Can we help you?', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for answers',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                Card(
                  color: Colors.grey.shade100,
                  child: ListTile(
                    title: const Text('Can I export my notes as pdf?'),
                    subtitle: const Text('The short answer is: Not directly'),
                    trailing: const Icon(Icons.remove_red_eye, color: blue),
                  ),
                ),
                // you can add more FAQs here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
