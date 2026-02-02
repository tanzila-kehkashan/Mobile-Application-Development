import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexus/services/theme_provider.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || email.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'raqeeb0318212@gmail.com',
      query: _encodeQueryParameters({
        'subject': 'Nexus App Contact: $name',
        'body': 'Name: $name\nEmail: $email\n\nMessage:\n$description',
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        
        if (mounted) {
          // Clear form
          _nameController.clear();
          _emailController.clear();
          _descriptionController.clear();
          
          // Show confirmation
          _showConfirmationDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email client. Please email raqeeb0318212@gmail.com directly.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Message Sent!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for contacting us. We\'ll get back to you at the email you provided.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCBB8A1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Us',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'d love to hear from you. Send us a message and we\'ll respond as soon as possible.',
              style: TextStyle(
                fontSize: 15,
                color: themeProvider.secondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Your Name',
              icon: Icons.person_outline,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            
            // Email Field
            _buildTextField(
              controller: _emailController,
              label: 'Your Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            
            // Description Field
            _buildTextField(
              controller: _descriptionController,
              label: 'Your Message',
              icon: Icons.message_outlined,
              maxLines: 5,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Direct contact info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.email,
                    size: 32,
                    color: themeProvider.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Or email us directly at:',
                    style: TextStyle(
                      color: themeProvider.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    'raqeeb0318212@gmail.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: themeProvider.textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: themeProvider.secondaryTextColor),
          prefixIcon: Icon(icon, color: themeProvider.secondaryTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
