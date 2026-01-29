import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart'; // Make sure this import matches your file
import 'sign_in.dart';   // Import your login screen if needed

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // 1. Check if already verified
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // 2. Send the verification email immediately
      sendVerificationEmail();

      // 3. Start a timer to check status every 3 seconds
      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // We must reload the user to get the latest status from Firebase
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // EMAIL VERIFIED! Go to Dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Verified! Logging in..."), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending email: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      // If verified (just in case the redirect is slow), show simple center text
      return const Scaffold(
        body: Center(child: Text("Email Verified!", style: TextStyle(fontSize: 20))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A1E35),
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 100, color: Colors.cyan),
            const SizedBox(height: 20),
            const Text(
              "Check your Email",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "We sent a verification link to ${FirebaseAuth.instance.currentUser?.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.cyan),
            const SizedBox(height: 20),
            const Text(
              "Verifying...",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 50),

            // Resend Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.email, color: Colors.black),
              label: const Text(
                "Resend Email",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              onPressed: canResendEmail ? sendVerificationEmail : null,
            ),

            const SizedBox(height: 20),

            // Cancel Button
            TextButton(
              onPressed: () async {
                timer?.cancel();
                await FirebaseAuth.instance.signOut();
                if(mounted) Navigator.pop(context); // Go back to Sign In
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.cyan)),
            )
          ],
        ),
      ),
    );
  }
}