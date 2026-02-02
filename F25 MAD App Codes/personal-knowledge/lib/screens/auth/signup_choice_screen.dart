import 'package:flutter/material.dart';
import 'signup_form_screen.dart';
import 'login_screen.dart';

import '../../utils/responsive_utils.dart';
import '../../utils/page_transitions.dart';
class SignupChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingM(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.auto_awesome, size: 72),
              const SizedBox(height: 24),
              Text(
                "Explore the app",
                style: TextStyle(fontSize: AppSizes.fontM(context), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "Manage your money in one place and always stay in control.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppSizes.fontM(context), color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Google sign-in logic
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text("Continue with Google"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, context.responsive.buttonHeight()),
                  backgroundColor: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Apple sign-in logic
                },
                icon: const Icon(Icons.apple),
                label: const Text("Continue with Apple"),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, context.responsive.buttonHeight()),
                ),
              ),
              const SizedBox(height: 24),
              const Text("or", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    FadeSlidePageRoute(page: SignUpFormScreen()),
                  );
                },
                child: const Text("Create account"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, context.responsive.buttonHeight()),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    FadeSlidePageRoute(page: const LoginScreen()),
                  );
                },
                child: const Text("Already have an account? Log in"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
