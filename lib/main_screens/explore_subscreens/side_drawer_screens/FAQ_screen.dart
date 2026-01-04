import 'package:flutter/material.dart';

import 'about_us_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _faqCategories = [
    {
      'title': 'Tickets and Bookings',
      'icon': Icons.confirmation_number_outlined,
      'color': const Color(0xFF5B4EFF),
      'questions': [
        {
          'question': 'What if an event is posponed?',
          'answer':
          'If an event is postponed, your tickets will remain valid for the new date. You will receive a notification about the change.',
        },
        {
          'question': 'Can I change the seat I selected?',
          'answer':
          'Yes, you can change your seat selection up to 24 hours before the event starts through your booking details.',
        },
        {
          'question': 'How can I share an event with friends?',
          'answer':
          'Tap the share button on any event page and choose how you want to share it with your friends.',
        },
      ],
    },
    {
      'title': 'Payments and Refunds',
      'icon': Icons.payments_outlined,
      'color': const Color(0xFF00D9A5),
      'questions': [
        {
          'question': 'What payment methods are accepted?',
          'answer':
          'We accept all major credit cards, debit cards, PayPal, and Apple Pay/Google Pay.',
        },
        {
          'question': 'How do I request a refund?',
          'answer':
          'Refunds can be requested through your booking details. Refund policies vary by event.',
        },
        {
          'question': 'When will I receive my refund?',
          'answer':
          'Refunds are typically processed within 5-7 business days after approval.',
        },
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FAQ\'s',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search your doubts',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
          ),
          // FAQ Categories
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _faqCategories.length,
              itemBuilder: (context, categoryIndex) {
                final category = _faqCategories[categoryIndex];
                return _buildCategoryCard(category, categoryIndex);
              },
            ),
          ),
          // About Us Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline, size: 20),
              label: const Text('About Us'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5B4EFF),
                side: const BorderSide(
                  color: Color(0xFF5B4EFF),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int categoryIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category['color'].withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: category['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category['icon'],
                    color: category['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: category['color'],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Questions List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category['questions'].length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, questionIndex) {
              final globalIndex = categoryIndex * 100 + questionIndex;
              final question = category['questions'][questionIndex];
              final isExpanded = _expandedIndex == globalIndex;

              return InkWell(
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : globalIndex;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question['question'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        Text(
                          question['answer'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}