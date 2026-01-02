import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: settings.isColorBlindMode 
                  ? AppColors.yellow 
                  : AppColors.primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.translate('settings') ?? 'Settings',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
              color: theme.scaffoldBackgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.translate('appearance') ?? 'Appearance',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      icon: Icons.palette_outlined,
                      title: AppLocalizations.of(context)?.translate('color_blind_mode') ?? 'Color Blind Mode',
                      trailing: Switch(
                        value: settings.isColorBlindMode,
                        onChanged: (value) => settings.toggleColorBlindMode(value),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      icon: Icons.dark_mode_outlined,
                      title: AppLocalizations.of(context)?.translate('dark_mode') ?? 'Dark Mode',
                      trailing: Switch(
                        value: settings.isDarkMode,
                        onChanged: (value) => settings.toggleDarkMode(value),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)?.translate('preferences') ?? 'Preferences',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      icon: Icons.notifications_outlined,
                      title: AppLocalizations.of(context)?.translate('notifications') ?? 'Notifications',
                      trailing: Switch(
                        value: settings.notificationsEnabled,
                        onChanged: (value) => settings.toggleNotifications(value),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      icon: Icons.language_outlined,
                      title: AppLocalizations.of(context)?.translate('language') ?? 'Language',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getLanguageName(settings.locale.languageCode),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                        ],
                      ),
                      onTap: () => _showLanguageDialog(context, settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es': return 'Español';
      case 'fr': return 'Français';
      default: return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsService settings) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(localizations?.translate('select_language') ?? 'Select Language'),
        children: [
          _buildLanguageOption(context, settings, 'English', 'en'),
          _buildLanguageOption(context, settings, 'Español', 'es'),
          _buildLanguageOption(context, settings, 'Français', 'fr'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, 
    SettingsService settings, 
    String name, 
    String code
  ) {
    return SimpleDialogOption(
      onPressed: () {
        settings.setLanguage(code);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            if (settings.locale.languageCode == code)
              Icon(Icons.check, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}

