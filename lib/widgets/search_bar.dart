import 'package:flutter/material.dart';
import '../main_screens/search_screen.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final VoidCallback?  onTap;

  const SearchBarWidget({
    Key? key,
    this.hintText = 'Search.. .',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??  () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child:  Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius:  BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              hintText,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}