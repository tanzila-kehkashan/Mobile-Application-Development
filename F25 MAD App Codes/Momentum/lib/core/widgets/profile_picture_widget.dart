import 'dart:io';
import 'package:flutter/material.dart';

/// Reusable profile picture widget that shows image or initials
class ProfilePictureWidget extends StatelessWidget {
  final String? imagePath;
  final String name;
  final double size;
  final bool showEditButton;
  final VoidCallback? onEditTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderWidth;
  final Color? borderColor;

  const ProfilePictureWidget({
    super.key,
    this.imagePath,
    required this.name,
    this.size = 100,
    this.showEditButton = false,
    this.onEditTap,
    this.backgroundColor,
    this.textColor,
    this.borderWidth,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showEditButton ? onEditTap : null,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: borderWidth != null
                  ? Border.all(
                      color: borderColor ?? const Color(0xFFE8FF78),
                      width: borderWidth!,
                    )
                  : null,
            ),
            child: ClipOval(
              child: _buildContent(),
            ),
          ),
          if (showEditButton)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FF78),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF201A3F),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: const Color(0xFF201A3F),
                  size: size * 0.18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Check if image path exists and file exists
    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      return FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildInitials();
              },
            );
          }
          return _buildInitials();
        },
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    final initials = _getInitials(name);
    final bgColor = backgroundColor ?? const Color(0xFF4A3D7E);
    final fgColor = textColor ?? Colors.white;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: fgColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Smaller profile avatar for lists and app bars
class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final String name;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imagePath,
    required this.name,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ProfilePictureWidget(
        imagePath: imagePath,
        name: name,
        size: size,
        showEditButton: false,
      ),
    );
  }
}

/// Hero profile picture for profile screens
class HeroProfilePicture extends StatelessWidget {
  final String? imagePath;
  final String name;
  final VoidCallback? onEditTap;

  const HeroProfilePicture({
    super.key,
    this.imagePath,
    required this.name,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      imagePath: imagePath,
      name: name,
      size: 120,
      showEditButton: true,
      onEditTap: onEditTap,
      borderWidth: 3,
      borderColor: const Color(0xFFE8FF78),
    );
  }
}
