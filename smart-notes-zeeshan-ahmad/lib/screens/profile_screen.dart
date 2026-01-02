import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';
import '../services/note_service.dart';
import '../services/local_storage_service.dart';
import '../services/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Stats variables
  int _totalNotes = 0;
  int _scannedNotes = 0;

  // User Profile variables
  String _fullName = "Loading...";
  String _email = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // 1. Load Note Statistics
    final noteService = Provider.of<NoteService>(context, listen: false);
    // Assuming your NoteService handles fetching notes for the specific user internally
    final notesStream = noteService.getNotes();

    // We listen to the first value of the stream to get current stats
    final notes = await notesStream.first;

    // 2. Load User Profile Data
    User? currentUser = FirebaseAuth.instance.currentUser;
    String nameFetch = "User";
    String emailFetch = "";

    if (currentUser != null) {
      emailFetch = currentUser.email ?? "No Email";
      
      // Try Local Storage First
      final localData = await LocalStorageService().getUser();
      if (localData['name'] != null) {
        nameFetch = localData['name']!;
      }
      if (localData['email'] != null) {
        emailFetch = localData['email']!;
      }

      try {
        // Fetch custom details (like Full Name) from Firestore
        // Assuming you have a collection named 'users' with the document ID as the User's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          // Change 'fullName' to whatever key you used when saving the user to Firestore
          nameFetch = data['fullName'] ?? data['name'] ?? "User";
        } else {
          // Fallback if no Firestore doc exists, try to use Auth Display Name
          nameFetch = currentUser.displayName ?? "User";
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        nameFetch = "Error loading name";
      }
    }

    if (!mounted) return;

    setState(() {
      _totalNotes = notes.length;
      _scannedNotes = notes.where((note) => note.extractedText != null).length;
      _fullName = nameFetch;
      _email = emailFetch;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsService>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine header color based on mode
    final headerColor = settings.isColorBlindMode 
        ? AppColors.yellow 
        : AppColors.primaryBlue;
    final headerTextColor = settings.isColorBlindMode ? Colors.black : Colors.white;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: headerTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    localizations?.translate('profile') ?? 'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: headerTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? theme.scaffoldBackgroundColor : AppColors.lightGray,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileCard(context, theme, localizations),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizations?.translate('account_info') ?? 'Account Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAccountInfoCard(
                      context: context,
                      theme: theme,
                      icon: Icons.person_outline,
                      label: localizations?.translate('full_name') ?? 'Full Name',
                      value: _fullName,
                    ),
                    const SizedBox(height: 12),
                    _buildAccountInfoCard(
                      context: context,
                      theme: theme,
                      icon: Icons.email_outlined,
                      label: localizations?.translate('email') ?? 'Email',
                      value: _email,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizations?.translate('statistics') ?? 'Statistics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatisticsCard(context, theme, localizations),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme, AppLocalizations? localizations) {
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsService>(context, listen: false);
    
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: settings.isColorBlindMode 
            ? const BorderSide(color: Colors.black, width: 2) 
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: settings.isColorBlindMode ? AppColors.yellow.withOpacity(0.3) : AppColors.lightBlue,
                shape: BoxShape.circle,
                border: settings.isColorBlindMode 
                    ? Border.all(color: Colors.black, width: 2) 
                    : null,
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: settings.isColorBlindMode ? Colors.black : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showEditProfileDialog(context, localizations),
                style: ElevatedButton.styleFrom(
                  backgroundColor: settings.isColorBlindMode ? AppColors.yellow : AppColors.primaryBlue,
                  foregroundColor: settings.isColorBlindMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: settings.isColorBlindMode 
                        ? const BorderSide(color: Colors.black, width: 2) 
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  localizations?.translate('edit_profile') ?? 'Edit Profile',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppLocalizations? localizations) {
    final TextEditingController nameController = TextEditingController(text: _fullName);
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        title: Text(
          localizations?.translate('update_profile') ?? 'Update Profile',
          style: theme.dialogTheme.titleTextStyle,
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: localizations?.translate('full_name') ?? 'Full Name',
            hintText: localizations?.translate('enter_name') ?? 'Enter your name',
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations?.translate('cancel') ?? 'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != _fullName) {
                await _updateProfile(newName);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(localizations?.translate('save') ?? 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String newName) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'fullName': newName}, SetOptions(merge: true));

      // Update local storage
      await LocalStorageService().saveUser(newName, _email);

      // Update UI
      if (mounted) {
        setState(() {
          _fullName = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Widget _buildAccountInfoCard({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsService>(context, listen: false);
    
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: settings.isColorBlindMode 
            ? const BorderSide(color: Colors.black, width: 2) 
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: settings.isColorBlindMode ? Colors.black : theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
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

  Widget _buildStatisticsCard(BuildContext context, ThemeData theme, AppLocalizations? localizations) {
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsService>(context, listen: false);
    
    final statBgColor = settings.isColorBlindMode 
        ? AppColors.yellow.withOpacity(0.3) 
        : (isDark ? theme.colorScheme.primary.withOpacity(0.2) : AppColors.lightBlue);
    final statTextColor = settings.isColorBlindMode 
        ? Colors.black 
        : (isDark ? Colors.white : AppColors.primaryBlue);
    
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: settings.isColorBlindMode 
            ? const BorderSide(color: Colors.black, width: 2) 
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: settings.isColorBlindMode 
                      ? Border.all(color: Colors.black, width: 2) 
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      '$_totalNotes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations?.translate('total_notes') ?? 'Total Notes',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontWeight: settings.isColorBlindMode ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: settings.isColorBlindMode 
                      ? Border.all(color: Colors.black, width: 2) 
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      '$_scannedNotes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations?.translate('scanned_notes') ?? 'Scanned',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontWeight: settings.isColorBlindMode ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}