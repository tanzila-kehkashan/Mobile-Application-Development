import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_Screen.dart';
import 'services/auth_service.dart';
import 'services/theme_provider.dart';
import 'services/favorites_service.dart';
import 'services/language_provider.dart';
import 'map_screen.dart';
import 'profile_settings.dart';
import 'paymentmethod.dart';
import 'about_screen.dart';
import 'help_faq_screen.dart';
import 'contact_feedback_screen.dart';
import 'notifications_screen.dart';
import 'privacy_policy_screen.dart';
import 'suppliers_screen.dart';
import 'transactions_screen.dart';
import 'sales_screen.dart';
import 'purchases_screen.dart';

void main() {
  runApp(const MyApp());
}

// --- 1. Custom Theme & Colors ---
class AppColors {
  // Light mode colors
  static const Color accentOrange = Color(0xFFE08F4C);
  static const Color primaryText = Colors.black;
  static const Color backgroundColor = Color(0xFFF0F4F9);
  static const Color buttonColor = Color(0xFF70B8C0);
  static const Color illustrationColor = Color(0xFF6A99E0);
  static const Color textFieldBackground = Colors.white;
  static const Color inactiveDotColor = Color(0xFFE0E0E0);
  static const Color appBarArrowColor = Colors.black;
  static const Color dividerColor = Color(0xFFE5E5E5);
  static const Color editProfileBlue = Color(0xFF6A99E0);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  static const Color darkDivider = Color(0xFF3C3C3C);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Inventory',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.appBarArrowColor),
        ),
      ),
      home: const MyProfilePage(),
    );
  }
}

// --- 2. Custom List Tile Widget for Settings ---
class SettingListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showDivider;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingListItem({
    super.key,
    required this.icon,
    required this.title,
    this.showDivider = false,
    this.iconColor = AppColors.primaryText,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryText;
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: isDark ? Colors.white70 : iconColor,
            size: 24,
          ),
          title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white60 : AppColors.primaryText,
              ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(
              color: isDark ? AppColors.darkDivider : AppColors.dividerColor,
              thickness: 1,
              height: 1,
            ),
          ),
      ],
    );
  }
}

// --- 3. My Profile Page ---
class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  String? _profileImageUrl;
  double _textSize = 1.0; // 0.85 = Small, 1.0 = Medium, 1.15 = Large

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _profileImageUrl = _user?.photoURL;
    _loadSavedLanguage();
    _loadProfileImageFromFirestore();
  }

  Future<void> _loadProfileImageFromFirestore() async {
    if (_user?.uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (doc.exists && doc.data()?['profileImage'] != null) {
        if (mounted) {
          setState(() {
            _profileImageUrl = doc.data()!['profileImage'];
          });
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _loadSavedLanguage() async {
    await languageProvider.init();
    if (mounted) {
      setState(() {
        _selectedLanguage = languageProvider.currentLanguage;
      });
    }
  }

  Future<void> _saveLanguage(String language) async {
    await languageProvider.setLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  // Helper to get translation
  String tr(String key) => languageProvider.translate(key);

  String get _userName {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    return _user?.email?.split('@').first ?? 'User';
  }

  String get _userEmail {
    return _user?.email ?? 'No email';
  }

  Widget _buildProfileAvatar() {
    final imageUrl = _profileImageUrl ?? _user?.photoURL;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if it's a base64 data URL
      if (imageUrl.startsWith('data:image')) {
        try {
          final base64String = imageUrl.split(',').last;
          final bytes = base64Decode(base64String);
          return CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.illustrationColor,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (e) {
          print('Error decoding base64 image: $e');
        }
      } else {
        // Regular URL
        return CircleAvatar(
          radius: 35,
          backgroundColor: AppColors.illustrationColor,
          backgroundImage: NetworkImage(
            '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}',
          ),
          onBackgroundImageError: (_, __) {},
        );
      }
    }

    // Default avatar
    return const CircleAvatar(
      radius: 35,
      backgroundColor: AppColors.illustrationColor,
      child: Icon(Icons.person, size: 40, color: Colors.white),
    );
  }

  void _showEditProfileDialog() async {
    // Navigate to profile settings page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSettingsPage()),
    );

    // Refresh user data if profile was updated
    if (result == true && mounted) {
      print('Profile updated, refreshing user data...');
      await _auth.currentUser?.reload();
      final updatedUser = _auth.currentUser;
      print('Updated user photoURL: ${updatedUser?.photoURL}');

      // Clear image cache to force reload of new profile photo
      imageCache.clear();
      imageCache.clearLiveImages();

      // Also reload from Firestore
      await _loadProfileImageFromFirestore();

      setState(() {
        _user = updatedUser;
        _profileImageUrl = updatedUser?.photoURL ?? _profileImageUrl;
      });
      print('Profile page refreshed');
    }
  }

  void _showFavourites() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.favorite, color: Colors.pink.shade600),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'My Favourites',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: favoritesService.getFavoritesList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final favorites = snapshot.data ?? [];

                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No favourites yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap the heart icon on products\nto add them here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return StatefulBuilder(
                    builder: (context, setListState) {
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final fav = favorites[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.illustrationColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      fav['imageUrl'] != null &&
                                          fav['imageUrl'].toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            fav['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.inventory_2_outlined,
                                              color:
                                                  AppColors.illustrationColor,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.inventory_2_outlined,
                                          color: AppColors.illustrationColor,
                                        ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fav['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        fav['category'] ?? 'No category',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'PKR ${(fav['price'] ?? 0).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () async {
                                        await favoritesService
                                            .removeFromFavorites(fav['id']);
                                        favorites.removeAt(index);
                                        setListState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Removed from favourites',
                                            ),
                                            backgroundColor: Colors.grey,
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.pink,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    String tempSelectedLanguage = _selectedLanguage;

    final languages = [
      {'name': 'English', 'code': 'English'},
      {'name': 'Urdu - اردو', 'code': 'Urdu'},
      {'name': 'العربية (Arabic)', 'code': 'Arabic'},
      {'name': 'Español (Spanish)', 'code': 'Spanish'},
      {'name': 'Français (French)', 'code': 'French'},
      {'name': '中文 (Chinese)', 'code': 'Chinese'},
      {'name': 'हिंदी (Hindi)', 'code': 'Hindi'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Language',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...languages.map((lang) {
                final isSelected = tempSelectedLanguage == lang['code'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6A99E0).withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF6A99E0), width: 2)
                        : null,
                  ),
                  child: ListTile(
                    title: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF6A99E0)
                            : Colors.black,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF6A99E0),
                          )
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      setModalState(() {
                        tempSelectedLanguage = lang['code']!;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedLanguage = tempSelectedLanguage;
                    });
                    _saveLanguage(tempSelectedLanguage);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 10),
                            Text('Language changed to $tempSelectedLanguage'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A99E0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Note: Language preference is saved. Full translation coming soon!',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisplaySettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Display Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                  Navigator.pop(context);
                  setState(() {}); // Refresh this screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Dark mode enabled!' : 'Light mode enabled!',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text Size'),
                subtitle: Text(_getTextSizeLabel()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showTextSizeSelector();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTextSizeLabel() {
    if (_textSize <= 0.85) return 'Small';
    if (_textSize >= 1.15) return 'Large';
    return 'Medium';
  }

  void _showTextSizeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Text Size',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your preferred text size',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _buildTextSizeOption('Small', 0.85, setModalState),
              _buildTextSizeOption('Medium', 1.0, setModalState),
              _buildTextSizeOption('Large', 1.15, setModalState),
              const SizedBox(height: 16),
              Text(
                'Note: Text size preference is saved locally.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSizeOption(
    String label,
    double size,
    StateSetter setModalState,
  ) {
    final isSelected = (_textSize - size).abs() < 0.01;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16 * size,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text('Aa Bb Cc', style: TextStyle(fontSize: 14 * size)),
      onTap: () {
        setModalState(() {});
        setState(() {
          _textSize = size;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Text size set to $label'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showSubscriptionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber.shade600),
            const SizedBox(width: 8),
            const Text('Subscription'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  const Text(
                    'Free Plan - Active',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Features included:'),
            const SizedBox(height: 8),
            _buildFeatureItem('Unlimited products'),
            _buildFeatureItem('Barcode scanning'),
            _buildFeatureItem('Low stock alerts'),
            _buildFeatureItem('Cloud backup'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _showLocationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Current Location'),
              subtitle: const Text('Pakistan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.green),
              title: const Text('Open Map'),
              subtitle: const Text('Select location on map'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Location is used for inventory management and regional settings.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary data stored on your device. Your products and account data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear History'),
        content: const Text(
          'This will clear your search history and recent activity. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _settingsItemWithNav(
                  Icons.notifications_outlined,
                  'Notifications',
                  'Manage alerts',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _settingsItemWithNav(
                  Icons.help_outline,
                  'Help & FAQ',
                  'FAQs and guidance',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
                    );
                  },
                ),
                _settingsItemWithNav(
                  Icons.feedback_outlined,
                  'Contact Us',
                  'Send feedback',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactFeedbackScreen(),
                      ),
                    );
                  },
                ),
                _settingsItemWithNav(
                  Icons.info_outline,
                  'About',
                  'App version & info',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                _settingsItemWithNav(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'Read our policy',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.illustrationColor),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title - Coming soon!')));
      },
    );
  }

  Widget _settingsItemWithNav(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.illustrationColor),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.appBarArrowColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          tr('my_profile'),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : AppColors.appBarArrowColor,
            ),
            onPressed: _showSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile Header Section ---
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 24.0,
                right: 24.0,
                bottom: 30.0,
              ),
              child: Row(
                children: [
                  // Profile Picture
                  _buildProfileAvatar(),
                  const SizedBox(width: 15),
                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Text(
                          _userEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Edit Profile Button
                        GestureDetector(
                          onTap: _showEditProfileDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.editProfileBlue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Section 1: Core Features ---
            SettingListItem(
              icon: Icons.favorite_border,
              title: tr('favourites'),
              showDivider: true,
              onTap: _showFavourites,
            ),

            const SizedBox(height: 15),

            // --- Section 2: Account Settings ---
            InkWell(
              onTap: () {
                print('Language tapped!');
                _showLanguageDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.language,
                      color: AppColors.primaryText,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        tr('languages'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    Text(
                      _selectedLanguage,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            SettingListItem(
              icon: Icons.location_on_outlined,
              title: tr('location'),
              onTap: _showLocationSettings,
            ),
            SettingListItem(
              icon: Icons.subscriptions_outlined,
              title: tr('subscription'),
              onTap: _showSubscriptionInfo,
            ),
            SettingListItem(
              icon: Icons.desktop_windows_outlined,
              title: tr('display'),
              showDivider: true,
              onTap: _showDisplaySettings,
            ),

            const SizedBox(height: 15),

            // --- Section 3: Utility & Logout ---
            SettingListItem(
              icon: Icons.delete_outline,
              title: tr('clear_cache'),
              onTap: _clearCache,
            ),
            SettingListItem(
              icon: Icons.access_time,
              title: tr('clear_history'),
              onTap: _clearHistory,
            ),
            SettingListItem(
              icon: Icons.logout,
              title: tr('log_out'),
              iconColor: Colors.red,
              onTap: _logout,
            ),

            // Final divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Divider(
                color: AppColors.dividerColor,
                thickness: 1,
                height: 1,
              ),
            ),

            // App Version
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'App Version 2.3',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
