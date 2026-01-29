import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
        title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: '1. Acceptance of Terms',
                content: 'By downloading, installing, or using the Momentum fitness application ("App"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the App.',
              ),
              _buildSection(
                title: '2. Description of Service',
                content: 'Momentum is a fitness tracking application that allows users to:\n\n• Track workouts and exercises\n• Monitor daily activity and progress\n• Set and achieve fitness goals\n• Manage personal health data\n\nThe App is provided for informational and fitness tracking purposes only and should not be considered medical advice.',
              ),
              _buildSection(
                title: '3. User Accounts',
                content: 'To use certain features of the App, you must create an account. You are responsible for:\n\n• Maintaining the confidentiality of your account credentials\n• All activities that occur under your account\n• Providing accurate and complete information\n• Updating your information as needed',
              ),
              _buildSection(
                title: '4. User Conduct',
                content: 'You agree not to:\n\n• Use the App for any unlawful purpose\n• Attempt to gain unauthorized access to our systems\n• Interfere with or disrupt the App\'s functionality\n• Upload malicious code or content\n• Impersonate any person or entity',
              ),
              _buildSection(
                title: '5. Health Disclaimer',
                content: 'The workout information and fitness tracking features in this App are for general informational purposes only. Before starting any exercise program, you should consult with a healthcare professional. We are not responsible for any injuries or health issues that may result from using our App.',
              ),
              _buildSection(
                title: '6. Intellectual Property',
                content: 'All content, features, and functionality of the App, including but not limited to text, graphics, logos, and software, are the exclusive property of Momentum and are protected by copyright, trademark, and other intellectual property laws.',
              ),
              _buildSection(
                title: '7. Privacy',
                content: 'Your privacy is important to us. Our collection and use of personal information is governed by our Privacy Policy. By using the App, you consent to our data practices as described in the Privacy Policy.',
              ),
              _buildSection(
                title: '8. Modifications to Service',
                content: 'We reserve the right to modify, suspend, or discontinue the App at any time without notice. We may also update these Terms from time to time. Continued use of the App after changes constitutes acceptance of the new terms.',
              ),
              _buildSection(
                title: '9. Limitation of Liability',
                content: 'To the maximum extent permitted by law, Momentum shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the App.',
              ),
              _buildSection(
                title: '10. Governing Law',
                content: 'These Terms shall be governed by and construed in accordance with the laws of your jurisdiction, without regard to its conflict of law provisions.',
              ),
              _buildSection(
                title: '11. Contact Information',
                content: 'If you have any questions about these Terms, please contact us at:\n\nEmail: support@momentum-app.com\nWebsite: www.momentum-app.com',
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3D7E),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFFE8FF78)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'By using Momentum, you agree to these Terms and Conditions.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE8FF78),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
