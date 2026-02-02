import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About Us',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6A99E0),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A99E0).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              'Smart Inventory',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F487B),
              ),
            ),
            const SizedBox(height: 8),

            // Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6A99E0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Color(0xFF6A99E0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // About Description
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'About the App',
              description:
                  'Smart Inventory is a comprehensive inventory management solution designed to help businesses track, manage, and optimize their stock levels efficiently. With features like barcode scanning, low stock alerts, and detailed reports, managing your inventory has never been easier.',
            ),
            const SizedBox(height: 16),

            // Mission
            _buildInfoCard(
              icon: Icons.flag_outlined,
              title: 'Our Mission',
              description:
                  'To empower businesses of all sizes with smart, intuitive tools that simplify inventory management and drive operational excellence.',
            ),
            const SizedBox(height: 16),

            // Features
            _buildInfoCard(
              icon: Icons.star_outline,
              title: 'Key Features',
              description:
                  '• Real-time inventory tracking\n• Barcode & QR code scanning\n• Low stock notifications\n• Comprehensive reports\n• Multi-user support\n• Cloud synchronization',
            ),
            const SizedBox(height: 16),

            // Developer Info
            _buildInfoCard(
              icon: Icons.code,
              title: 'Developed By',
              description:
                  'This application was developed with ❤️ by the Smart Inventory Team. We are committed to providing the best inventory management experience.',
            ),
            const SizedBox(height: 32),

            // Social Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.language, 'Website'),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.email_outlined, 'Email'),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.facebook, 'Facebook'),
              ],
            ),
            const SizedBox(height: 32),

            // Copyright
            Text(
              '© 2024 Smart Inventory. All rights reserved.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A99E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF6A99E0), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F487B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
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

  Widget _buildSocialButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF6A99E0)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
