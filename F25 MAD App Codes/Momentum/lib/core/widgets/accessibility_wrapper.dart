import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Wrapper widget that adds semantic labels for accessibility
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isLink;
  final bool isHeader;
  final bool isImage;
  final bool isEnabled;
  final bool excludeFromSemantics;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isLink = false,
    this.isHeader = false,
    this.isImage = false,
    this.isEnabled = true,
    this.excludeFromSemantics = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }
    
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      link: isLink,
      header: isHeader,
      image: isImage,
      enabled: isEnabled,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// Accessible button with proper semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: isEnabled,
      onTap: isEnabled ? onPressed : null,
      child: child,
    );
  }
}

/// Accessible text field wrapper
class AccessibleTextField extends StatelessWidget {
  final Widget textField;
  final String label;
  final String? hint;
  final String? error;
  final bool isRequired;

  const AccessibleTextField({
    super.key,
    required this.textField,
    required this.label,
    this.hint,
    this.error,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isRequired ? '$label, required' : label,
      hint: hint,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textField,
          if (error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}

/// Decorative image that is excluded from semantics
class DecorativeImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const DecorativeImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      ),
    );
  }
}

/// Screen reader announcement widget
class Announcement extends StatefulWidget {
  final String message;
  final Widget child;

  const Announcement({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  @override
  void initState() {
    super.initState();
    // Announce the message on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(widget.message, TextDirection.ltr);
    });
  }

  @override
  void didUpdateWidget(Announcement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      SemanticsService.announce(widget.message, TextDirection.ltr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension methods for common accessibility patterns
extension AccessibilityExtensions on Widget {
  /// Wrap with semantic label
  Widget withSemanticLabel(String label) {
    return Semantics(
      label: label,
      child: this,
    );
  }

  /// Mark as button
  Widget asButton(String label, {VoidCallback? onTap}) {
    return Semantics(
      label: label,
      button: true,
      onTap: onTap,
      child: this,
    );
  }

  /// Mark as header
  Widget asHeader() {
    return Semantics(
      header: true,
      child: this,
    );
  }

  /// Exclude from semantics tree
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Merge semantics of children
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}
