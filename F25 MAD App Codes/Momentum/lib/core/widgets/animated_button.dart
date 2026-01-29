import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animated button with press feedback and haptics
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleDown;
  final Duration duration;
  final bool enableHaptics;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxShadow? shadow;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptics = true,
    this.backgroundColor,
    this.borderRadius = 30,
    this.padding,
    this.shadow,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    
    setState(() => _isPressed = true);
    _controller.forward();
    
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.duration,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.shadow != null
                    ? [
                        BoxShadow(
                          color: widget.shadow!.color.withAlpha(_isPressed ? 51 : 102),
                          blurRadius: _isPressed ? widget.shadow!.blurRadius * 0.5 : widget.shadow!.blurRadius,
                          spreadRadius: widget.shadow!.spreadRadius,
                          offset: _isPressed
                              ? Offset(widget.shadow!.offset.dx * 0.5, widget.shadow!.offset.dy * 0.5)
                              : widget.shadow!.offset,
                        ),
                      ]
                    : null,
              ),
              padding: widget.padding,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Icon button with animated press feedback
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final bool enableHaptics;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.enableHaptics = true,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        if (widget.enableHaptics) {
          HapticFeedback.selectionClick();
        }
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: widget.backgroundColor != null
                  ? BoxDecoration(
                      color: widget.backgroundColor,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                widget.icon,
                size: widget.size,
                color: widget.color ?? Colors.white,
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
