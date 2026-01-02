import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OtpService {
  // Store OTPs temporarily in memory
  final Map<String, String> _otpStorage = {};
  
  // Expiration time for OTPs
  static const Duration _otpExpiration = Duration(minutes: 5);
  final Map<String, DateTime> _otpTimestamps = {};

  /// Generates a 6-digit random number string
  String generateOTP() {
    var rng = Random();
    return (100000 + rng.nextInt(900000)).toString();
  }

  /// Professional HTML email template with Smart Notes branding
  String _getEmailHtml(String otp) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Smart Notes - Verification Code</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f0f4f8;">
  <table role="presentation" style="width: 100%; border-collapse: collapse;">
    <tr>
      <td align="center" style="padding: 40px 0;">
        <table role="presentation" style="width: 100%; max-width: 600px; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 24px rgba(0, 0, 0, 0.1);">
          
          <!-- Header with Logo -->
          <tr>
            <td style="background: linear-gradient(135deg, #4285F4 0%, #1a73e8 100%); padding: 40px 40px 30px; border-radius: 16px 16px 0 0; text-align: center;">
              <!-- App Icon/Logo -->
              <div style="width: 80px; height: 80px; background-color: #ffffff; border-radius: 20px; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);">
                <table role="presentation" style="width: 80px; height: 80px;">
                  <tr>
                    <td align="center" valign="middle" style="background-color: #ffffff; border-radius: 20px;">
                      <span style="font-size: 36px; font-weight: bold; color: #4285F4;">S</span>
                    </td>
                  </tr>
                </table>
              </div>
              <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700; letter-spacing: -0.5px;">Smart Notes</h1>
              <p style="margin: 8px 0 0; color: rgba(255, 255, 255, 0.9); font-size: 14px;">Capture. Convert. Create.</p>
            </td>
          </tr>
          
          <!-- Main Content -->
          <tr>
            <td style="padding: 40px;">
              <h2 style="margin: 0 0 16px; color: #1a1a2e; font-size: 24px; font-weight: 600; text-align: center;">Verification Code</h2>
              <p style="margin: 0 0 30px; color: #4a5568; font-size: 16px; line-height: 1.6; text-align: center;">
                Hello! You've requested to reset your password. Use the verification code below to proceed:
              </p>
              
              <!-- OTP Code Box -->
              <div style="background: linear-gradient(135deg, #e8f0fe 0%, #d2e3fc 100%); border: 2px solid #4285F4; border-radius: 12px; padding: 24px; text-align: center; margin: 0 0 30px;">
                <p style="margin: 0 0 8px; color: #4285F4; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 2px;">Your Code</p>
                <p style="margin: 0; color: #1a73e8; font-size: 40px; font-weight: 700; letter-spacing: 8px; font-family: 'Courier New', monospace;">$otp</p>
              </div>
              
              <!-- Expiry Notice -->
              <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 16px; border-radius: 0 8px 8px 0; margin: 0 0 30px;">
                <p style="margin: 0; color: #856404; font-size: 14px;">
                  <strong>⏱ This code expires in 5 minutes.</strong><br>
                  For security reasons, please use this code promptly.
                </p>
              </div>
              
              <!-- Security Notice -->
              <p style="margin: 0; color: #718096; font-size: 14px; line-height: 1.6; text-align: center;">
                If you didn't request this code, please ignore this email or contact support if you have concerns.
              </p>
            </td>
          </tr>
          
          <!-- Footer -->
          <tr>
            <td style="background-color: #f7fafc; padding: 30px 40px; border-radius: 0 0 16px 16px; border-top: 1px solid #e2e8f0;">
              <table role="presentation" style="width: 100%;">
                <tr>
                  <td style="text-align: center;">
                    <p style="margin: 0 0 8px; color: #4285F4; font-size: 16px; font-weight: 600;">Smart Notes</p>
                    <p style="margin: 0 0 16px; color: #a0aec0; font-size: 13px;">Your intelligent note-taking companion</p>
                    <p style="margin: 0; color: #a0aec0; font-size: 12px;">
                      © ${DateTime.now().year} Smart Notes. All rights reserved.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  /// Sends the OTP to the given email via SMTP
  Future<bool> sendOTP(String email) async {
    try {
      // Generate new OTP
      final otp = generateOTP();
      
      // Store OTP with timestamp
      _otpStorage[email] = otp;
      _otpTimestamps[email] = DateTime.now();

      // Web platform doesn't support dart:io, so SMTP won't work
      // Fall back to simulation mode on web
      if (kIsWeb) {
        print('🌐 Running on Web - SMTP not supported. Using simulation mode.');
        print('📧 In production, use a backend API/Cloud Function to send emails.');
        await _simulateSending(email, otp);
        return true;
      }

      // Load environment variables
      String? smtpEmail;
      String? smtpPassword;
      String? smtpHost;
      int? smtpPort;

      try {
        smtpEmail = dotenv.env['SMTP_EMAIL'];
        smtpPassword = dotenv.env['SMTP_PASSWORD'];
        smtpHost = dotenv.env['SMTP_HOST'];
        smtpPort = int.tryParse(dotenv.env['SMTP_PORT'] ?? '587');
      } catch (e) {
        print('⚠️ First attempt to read env failed: $e');
        try {
          await dotenv.load(fileName: ".env");
          smtpEmail = dotenv.env['SMTP_EMAIL'];
          smtpPassword = dotenv.env['SMTP_PASSWORD'];
          smtpHost = dotenv.env['SMTP_HOST'];
          smtpPort = int.tryParse(dotenv.env['SMTP_PORT'] ?? '587');
        } catch (loadError) {
          print('⚠️ Failed to load .env file: $loadError');
        }
      }

      // Default values
      smtpHost ??= 'smtp.gmail.com';
      smtpPort ??= 587;

      // Check credentials
      if (smtpEmail == null || smtpEmail.isEmpty || 
          smtpPassword == null || smtpPassword.isEmpty) {
        print('⚠️ SMTP Credentials missing. Falling back to simulation.');
        print('   SMTP_EMAIL: ${smtpEmail ?? "not set"}');
        print('   SMTP_PASSWORD: ${smtpPassword != null ? "***set***" : "not set"}');
        await _simulateSending(email, otp);
        return true;
      }

      print('📧 Attempting to send OTP email to: $email');
      print('   Using SMTP Host: $smtpHost:$smtpPort');
      print('   From: $smtpEmail');

      // Configure SMTP Server - Use Gmail-specific helper for Gmail
      late SmtpServer smtpServer;
      
      if (smtpHost == 'smtp.gmail.com') {
        // Use the built-in gmail helper which handles TLS/STARTTLS properly
        smtpServer = gmail(smtpEmail, smtpPassword);
        print('   Using Gmail SMTP helper');
      } else {
        // For other SMTP servers, use manual configuration
        smtpServer = SmtpServer(
          smtpHost,
          port: smtpPort,
          username: smtpEmail,
          password: smtpPassword,
          ssl: smtpPort == 465,
          allowInsecure: smtpPort != 465 && smtpPort != 587,
        );
        print('   Using custom SMTP configuration');
      }
      
      // Create email message with professional template
      final message = Message()
        ..from = Address(smtpEmail, 'Smart Notes')
        ..recipients.add(email)
        ..subject = '🔐 Your Smart Notes Verification Code'
        ..text = '''
Smart Notes - Password Reset

Hello!

Your verification code is: $otp

This code will expire in 5 minutes.

If you didn't request this code, please ignore this email.

Best regards,
Smart Notes Team

© ${DateTime.now().year} Smart Notes. All rights reserved.
'''
        ..html = _getEmailHtml(otp);

      // Send email
      final sendReport = await send(message, smtpServer);
      print('✅ Email sent successfully: ${sendReport.toString()}');
      return true;
      
    } on MailerException catch (e) {
      print('❌ Email sending failed: ${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      
      // Fallback to simulation for testing
      print('⚠️ Falling back to simulation mode.');
      await _simulateSending(email, _otpStorage[email] ?? generateOTP());
      return true;
      
    } catch (e) {
      print('❌ Unexpected error: ${e.toString()}');
      return false;
    }
  }

  /// Simulates sending an email (for testing without SMTP)
  Future<void> _simulateSending(String email, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📧 [SIMULATED EMAIL - Smart Notes]');
    print('To: $email');
    print('Subject: 🔐 Your Smart Notes Verification Code');
    print('');
    print('Your verification code is: $otp');
    print('This code expires in 5 minutes.');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Verifies if the provided OTP matches the stored one
  Future<bool> verifyOTP(String email, String inputOtp) async {
    // Check if OTP exists
    if (!_otpStorage.containsKey(email)) {
      print('❌ No OTP found for email: $email');
      return false;
    }

    // Check expiration
    final timestamp = _otpTimestamps[email];
    if (timestamp != null && 
        DateTime.now().difference(timestamp) > _otpExpiration) {
      print('❌ OTP expired for email: $email');
      _otpStorage.remove(email);
      _otpTimestamps.remove(email);
      return false;
    }

    // Check match
    if (_otpStorage[email] == inputOtp) {
      print('✅ OTP verified successfully for: $email');
      // Clear OTP after successful verification
      _otpStorage.remove(email);
      _otpTimestamps.remove(email);
      return true;
    }

    print('❌ Invalid OTP for email: $email');
    return false;
  }

  /// Resend OTP to email
  Future<bool> resendOTP(String email) async {
    print('🔄 Resending OTP to: $email');
    return await sendOTP(email);
  }

  /// Clear OTP for a specific email
  void clearOTP(String email) {
    _otpStorage.remove(email);
    _otpTimestamps.remove(email);
    print('🗑️ OTP cleared for: $email');
  }

  /// Check if OTP exists and is still valid
  bool hasValidOTP(String email) {
    if (!_otpStorage.containsKey(email)) {
      return false;
    }

    final timestamp = _otpTimestamps[email];
    if (timestamp != null && 
        DateTime.now().difference(timestamp) > _otpExpiration) {
      _otpStorage.remove(email);
      _otpTimestamps.remove(email);
      return false;
    }

    return true;
  }
}