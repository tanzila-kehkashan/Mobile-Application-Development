import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus/services/theme_provider.dart';

class ColorChangeScreen extends StatefulWidget {
  const ColorChangeScreen({super.key});

  @override
  State<ColorChangeScreen> createState() => _ColorChangeScreenState();
}

class _ColorChangeScreenState extends State<ColorChangeScreen> {
  AppThemeMode? _selectedTheme;
  Color? _customColor;

  final List<Color> _customColorOptions = [
    const Color(0xFFE57373), // Red
    const Color(0xFFFFB74D), // Orange
    const Color(0xFFFFD54F), // Yellow
    const Color(0xFF81C784), // Green
    const Color(0xFF4FC3F7), // Light Blue
    const Color(0xFF7986CB), // Indigo
    const Color(0xFFBA68C8), // Purple
    const Color(0xFFF06292), // Pink
    const Color(0xFF90A4AE), // Blue Grey
    const Color(0xFFA1887F), // Brown
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        _selectedTheme = themeProvider.themeMode;
        _customColor = themeProvider.customColor;
      });
    });
  }

  Future<void> _applyTheme() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    if (_selectedTheme == AppThemeMode.custom && _customColor != null) {
      await themeProvider.setCustomColor(_customColor!);
    } else if (_selectedTheme != null) {
      await themeProvider.setThemeMode(_selectedTheme!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Theme applied successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
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
          'Theme & Colors',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Theme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a preset theme or create your own custom color scheme.',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

            // Preset Themes
            Text(
              'Preset Themes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Default Theme
            _buildThemeOption(
              title: 'Default',
              subtitle: 'The original Nexus theme',
              color: const Color(0xFFCBB8A1),
              isSelected: _selectedTheme == AppThemeMode.defaultTheme,
              onTap: () {
                setState(() {
                  _selectedTheme = AppThemeMode.defaultTheme;
                  _customColor = null;
                });
              },
              themeProvider: themeProvider,
            ),

            // Protopia (Red-Green colorblind friendly)
            _buildThemeOption(
              title: 'Protopia',
              subtitle: 'Red-Green colorblind friendly',
              color: const Color(0xFF2196F3),
              isSelected: _selectedTheme == AppThemeMode.protopia,
              onTap: () {
                setState(() {
                  _selectedTheme = AppThemeMode.protopia;
                  _customColor = null;
                });
              },
              themeProvider: themeProvider,
            ),

            // Deutropia (Blue-Yellow colorblind friendly)
            _buildThemeOption(
              title: 'Deutropia',
              subtitle: 'Blue-Yellow colorblind friendly',
              color: const Color(0xFF9C27B0),
              isSelected: _selectedTheme == AppThemeMode.deutropia,
              onTap: () {
                setState(() {
                  _selectedTheme = AppThemeMode.deutropia;
                  _customColor = null;
                });
              },
              themeProvider: themeProvider,
            ),

            const SizedBox(height: 32),

            // Custom Colors
            Text(
              'Custom Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your own accent color',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 16),

            // Color Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _customColorOptions.map((color) {
                  final isSelected = _selectedTheme == AppThemeMode.custom && 
                                     _customColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = AppThemeMode.custom;
                        _customColor = color;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Preview Section
            Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Preview Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _getPreviewColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Preview Button',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Preview Elements
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPreviewChip('Tag 1'),
                      _buildPreviewChip('Tag 2'),
                      _buildPreviewChip('Tag 3'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _applyTheme,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPreviewColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Apply Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getPreviewColor() {
    if (_selectedTheme == AppThemeMode.custom && _customColor != null) {
      return _customColor!;
    }
    switch (_selectedTheme) {
      case AppThemeMode.protopia:
        return const Color(0xFF2196F3);
      case AppThemeMode.deutropia:
        return const Color(0xFF9C27B0);
      case AppThemeMode.defaultTheme:
      default:
        return const Color(0xFFCBB8A1);
    }
  }

  Widget _buildPreviewChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getPreviewColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getPreviewColor()),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getPreviewColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: color, width: 2)
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
