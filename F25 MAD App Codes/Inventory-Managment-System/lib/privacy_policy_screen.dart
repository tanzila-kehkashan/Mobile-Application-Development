import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A99E0), Color(0xFF70B8C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
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
                      Icons.privacy_tip_outlined,
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
                          'Your Privacy Matters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Last updated: December 2024',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'Introduction',
              'Welcome to Smart Inventory. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our application.',
            ),

            _buildSection(
              'Information We Collect',
              '• Account Information: Name, email address, and profile picture when you create an account.\n\n'
                  '• Inventory Data: Product names, quantities, prices, images, and categories you add to your inventory.\n\n'
                  '• Usage Data: How you interact with the app, features used, and time spent.\n\n'
                  '• Device Information: Device type, operating system, and unique device identifiers.',
            ),

            _buildSection(
              'How We Use Your Information',
              '• To provide and maintain our inventory management service.\n\n'
                  '• To sync your inventory data across devices.\n\n'
                  '• To send notifications about low stock alerts.\n\n'
                  '• To improve our app based on usage patterns.\n\n'
                  '• To provide customer support when you contact us.',
            ),

            _buildSection(
              'Data Storage & Security',
              'Your data is stored securely on Firebase servers provided by Google. We implement industry-standard security measures including:\n\n'
                  '• End-to-end encryption for data transmission.\n\n'
                  '• Secure authentication using Firebase Auth.\n\n'
                  '• Regular security audits and updates.\n\n'
                  '• Access controls to protect your data.',
            ),

            _buildSection(
              'Data Sharing',
              'We do not sell, trade, or rent your personal information to third parties. We may share data only:\n\n'
                  '• With your consent.\n\n'
                  '• To comply with legal obligations.\n\n'
                  '• With service providers who assist in operating our app (e.g., Firebase, cloud storage).',
            ),

            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal data stored in our systems.\n\n'
                  '• Request correction of inaccurate data.\n\n'
                  '• Request deletion of your account and data.\n\n'
                  '• Export your inventory data.\n\n'
                  '• Opt-out of marketing communications.',
            ),

            _buildSection(
              'Children\'s Privacy',
              'Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
            ),

            _buildSection(
              'Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy in the app and updating the "Last updated" date.',
            ),

            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  '📧 Email: privacy@smartinventory.com\n\n'
                  '📱 In-app: Settings > Contact Us',
            ),

            const SizedBox(height: 24),

            // Accept Button
            Center(
              child: Text(
                'By using Smart Inventory, you agree to this Privacy Policy.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F487B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
