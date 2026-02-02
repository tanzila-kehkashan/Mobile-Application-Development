import 'package:flutter/material.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'How do I add a new product?',
      answer:
          'To add a new product, tap the "+" button on the dashboard or go to "New Product" from the menu. Fill in the product details like name, category, price, quantity, and optionally add an image. Tap "Save" to add the product to your inventory.',
    ),
    FaqItem(
      question: 'How does barcode scanning work?',
      answer:
          'Tap the barcode icon on the dashboard to open the scanner. Point your camera at the product barcode. The app will automatically detect and read the barcode. If the product exists, it will show details. If not, you can add it as a new product.',
    ),
    FaqItem(
      question: 'What are low stock alerts?',
      answer:
          'Low stock alerts notify you when a product\'s quantity falls below its minimum stock level. You can set the minimum stock level for each product. Products with low stock will be highlighted in red and appear in the "Low Stock" section.',
    ),
    FaqItem(
      question: 'How do I generate reports?',
      answer:
          'Go to "Reports" from the dashboard. You can generate various reports including inventory summary, low stock items, and sales reports. Select the date range and report type, then tap "Generate". You can also export reports as PDF or Excel files.',
    ),
    FaqItem(
      question: 'How do I manage multiple users?',
      answer:
          'The app supports multiple users with different access levels. Go to Settings > User Management to add new users, assign roles, and manage permissions. Each user will have their own login credentials.',
    ),
    FaqItem(
      question: 'Is my data backed up?',
      answer:
          'Yes! All your inventory data is automatically synced to the cloud in real-time. Your data is securely stored on Firebase servers and is backed up regularly. You can access your inventory from any device by logging in with your account.',
    ),
    FaqItem(
      question: 'How do I edit or delete a product?',
      answer:
          'To edit a product, tap on it to open details, then tap the edit icon. Make your changes and save. To delete, long-press on the product card or tap the delete icon in the product details screen. Confirm the deletion when prompted.',
    ),
    FaqItem(
      question: 'Can I use the app offline?',
      answer:
          'The app has limited offline functionality. You can view previously loaded inventory data offline. However, adding, editing, or deleting products requires an internet connection to sync with the cloud.',
    ),
    FaqItem(
      question: 'How do I export my inventory data?',
      answer:
          'Go to Settings > Export Data. Choose your preferred format (CSV, Excel, or PDF). Select the data you want to export and tap "Export". The file will be saved to your device\'s downloads folder.',
    ),
    FaqItem(
      question: 'How do I contact support?',
      answer:
          'You can reach our support team through the "Contact Us" section in the app. Fill out the contact form with your query, and we\'ll get back to you within 24-48 hours. You can also email us directly at support@smartinventory.com.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Help & FAQ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A99E0), Color(0xFF70B8C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A99E0).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Find answers to common questions below',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return _FaqTile(item: _faqItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final FaqItem item;

  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A99E0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.question_answer_outlined,
              color: Color(0xFF6A99E0),
              size: 20,
            ),
          ),
          title: Text(
            widget.item.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F487B),
            ),
          ),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isExpanded ? 0.5 : 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isExpanded
                    ? const Color(0xFF6A99E0)
                    : const Color(0xFF6A99E0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: _isExpanded ? Colors.white : const Color(0xFF6A99E0),
                size: 20,
              ),
            ),
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Text(
              widget.item.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
