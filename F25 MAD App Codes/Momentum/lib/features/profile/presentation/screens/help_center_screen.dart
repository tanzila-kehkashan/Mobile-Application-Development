import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQItem> _faqItems = [
    FAQItem(
      category: 'Getting Started',
      question: 'How do I create an account?',
      answer: 'To create an account:\n\n1. Open the Momentum app\n2. Tap "Register" on the welcome screen\n3. Enter your username, email, and password\n4. Tap "Register" to create your account\n\nYou\'ll be logged in automatically after registration.',
    ),
    FAQItem(
      category: 'Getting Started',
      question: 'How do I start a workout?',
      answer: 'To start a workout:\n\n1. Go to the Workouts tab\n2. Browse or search for a workout\n3. Tap on a workout to see details\n4. Tap "Start Workout" to begin\n5. Follow the on-screen instructions for each exercise',
    ),
    FAQItem(
      category: 'Workouts',
      question: 'Can I create custom workouts?',
      answer: 'Currently, Momentum offers a curated selection of pre-designed workouts. Custom workout creation is coming in a future update. Stay tuned!',
    ),
    FAQItem(
      category: 'Workouts',
      question: 'How is calorie burn calculated?',
      answer: 'Calorie burn is estimated based on:\n\n• The type of exercise\n• Duration of the workout\n• Intensity level\n\nThese are estimates and actual calorie burn may vary based on individual factors like weight, age, and fitness level.',
    ),
    FAQItem(
      category: 'Progress',
      question: 'How do I view my progress?',
      answer: 'To view your progress:\n\n1. Tap on the Progress tab in the bottom navigation\n2. Use the Week/Month/Year toggle to change time periods\n3. View your calorie trends, achievements, and personal bests',
    ),
    FAQItem(
      category: 'Progress',
      question: 'What are Personal Bests?',
      answer: 'Personal Bests track your top achievements across different metrics like longest workout, most calories burned in a single session, and workout streaks. These update automatically as you complete workouts.',
    ),
    FAQItem(
      category: 'Account',
      question: 'How do I reset my password?',
      answer: 'To reset your password:\n\n1. On the login screen, tap "Forgot Password?"\n2. Enter your registered email address\n3. Check your email for a password reset link\n4. Click the link and create a new password',
    ),
    FAQItem(
      category: 'Account',
      question: 'How do I update my profile?',
      answer: 'To update your profile:\n\n1. Go to the Profile tab\n2. Tap "Edit Profile"\n3. Update your name, email, weight, height, or date of birth\n4. Tap "Save" to confirm changes',
    ),
    FAQItem(
      category: 'Account',
      question: 'How do I delete my account?',
      answer: 'To delete your account:\n\n1. Go to Settings\n2. Tap "Security"\n3. Scroll to "Danger Zone"\n4. Tap "Delete Account"\n5. Confirm deletion\n\nWarning: This action is permanent and cannot be undone.',
    ),
    FAQItem(
      category: 'Technical',
      question: 'The app is crashing. What should I do?',
      answer: 'If the app is crashing:\n\n1. Force close the app completely\n2. Restart your device\n3. Check for app updates in the app store\n4. If the problem persists, try uninstalling and reinstalling\n5. Contact support if issues continue',
    ),
  ];

  List<FAQItem> get _filteredFAQs {
    if (_searchQuery.isEmpty) return _faqItems;
    return _faqItems.where((item) =>
      item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.category.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Help Center', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF4A3D7E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuickAction(
              icon: Icons.email_outlined,
              label: 'Email Support',
              onTap: () => _launchEmail(null),
            ),
          ),
          const SizedBox(height: 16),
          // FAQ List
          Expanded(
            child: _filteredFAQs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, color: Colors.white54, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'No results found',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredFAQs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFAQs[index];
                      return _buildFAQCard(faq);
                    },
                  ),
          ),
          // Contact Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF4A3D7E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Our support team is here to assist you',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showContactForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8FF78),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Color(0xFF201A3F)),
                        SizedBox(width: 8),
                        Text(
                          'Contact Support',
                          style: TextStyle(
                            color: Color(0xFF201A3F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactForm() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF4A3D7E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Subject',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF201A3F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Message',
                labelStyle: const TextStyle(color: Colors.white54),
                alignLabelWithHint: true,
                filled: true,
                fillColor: const Color(0xFF201A3F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final subject = subjectController.text.isNotEmpty 
                      ? subjectController.text 
                      : 'Momentum App Support';
                  final body = messageController.text;
                  Navigator.pop(context);
                  _launchEmailWithBody(subject, body);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8FF78),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Send Message',
                  style: TextStyle(
                    color: Color(0xFF201A3F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmailWithBody(String subject, String body) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'abdullahmehmood.tech@gmail.com',
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email: abdullahmehmood.tech@gmail.com'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(String? subject) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'abdullahmehmood.tech@gmail.com',
      queryParameters: {
        'subject': subject ?? 'Momentum App Support',
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email: abdullahmehmood.tech@gmail.com'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3D7E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE8FF78), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3D7E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF201A3F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.help_outline, color: Color(0xFFE8FF78), size: 20),
          ),
          title: Text(
            faq.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            faq.category,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white54,
          children: [
            Text(
              faq.answer,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String category;
  final String question;
  final String answer;

  FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}
