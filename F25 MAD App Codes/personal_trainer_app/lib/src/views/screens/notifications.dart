import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // State variables to track if switches are ON or OFF
  bool _pushNotification = true;
  bool _emailNotification = true;
  bool _workoutReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(
              'assets/images/back_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            // --- FIXED ICON CODE ---
            // Removed the extra 'decoration' and 'color' properties
            // so it shows the original icon just like the Dashboard.
            SizedBox(
              height: 35,
              width: 35,
              child: Image.asset(
                'assets/images/notification_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildNotificationOption(
                  title: "Push Notification",
                  subtitle: "workout reminder",
                  value: _pushNotification,
                  onChanged: (bool newValue) {
                    setState(() {
                      _pushNotification = newValue;
                    });
                  },
                ),
                const SizedBox(height: 30),
                _buildNotificationOption(
                  title: "Email Notification",
                  subtitle: "weekly progress report",
                  value: _emailNotification,
                  onChanged: (bool newValue) {
                    setState(() {
                      _emailNotification = newValue;
                    });
                  },
                ),
                const SizedBox(height: 30),
                _buildNotificationOption(
                  title: "Workout Reminders",
                  subtitle: "daily motivation",
                  value: _workoutReminder,
                  onChanged: (bool newValue) {
                    setState(() {
                      _workoutReminder = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Transform.scale(
          scale: 1.2,
          child: Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.all(Colors.white),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.blue;
              }
              return Colors.grey.withOpacity(0.5);
            }),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}