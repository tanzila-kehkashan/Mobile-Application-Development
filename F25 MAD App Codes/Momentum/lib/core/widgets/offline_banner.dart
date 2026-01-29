import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Banner widget that shows when the app is offline
class OfflineBanner extends StatefulWidget {
  final Widget child;
  
  const OfflineBanner({
    super.key,
    required this.child,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  bool _isOffline = false;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _initConnectivity();
  }

  void _initConnectivity() {
    final service = ConnectivityService();
    _isOffline = !service.isOnline;
    
    if (_isOffline) {
      _controller.forward();
    }
    
    _subscription = service.connectionStream.listen((isOnline) {
      setState(() {
        _isOffline = !isOnline;
        if (_isOffline) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.value == 0 && !_isOffline) {
              return const SizedBox.shrink();
            }
            
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _controller.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            color: const Color(0xFFFFA726),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'You\'re offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Data may be outdated',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Wrapper that shows a retry button when offline
class OfflineRetryWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final VoidCallback onRetry;
  final String? message;

  const OfflineRetryWrapper({
    super.key,
    required this.child,
    required this.isLoading,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();
    
    if (!connectivityService.isOnline && !isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'No internet connection',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your connection and try again',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8FF78),
                  foregroundColor: const Color(0xFF201A3F),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return child;
  }
}
