import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream of connectivity status changes
  Stream<bool> get connectionStream => _connectionStatusController.stream;
  
  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
    
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      _connectionStatusController.add(_isOnline);
    }
  }

  /// Check if currently connected
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    return _isOnline;
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectionStatusController.close();
  }
}

/// Mixin for widgets that need connectivity awareness
mixin ConnectivityAware<T extends Object> {
  bool _isOnline = true;
  StreamSubscription<bool>? _connectivitySubscription;
  
  bool get isOnline => _isOnline;

  void initConnectivity(void Function(bool) onConnectivityChanged) {
    final service = ConnectivityService();
    _isOnline = service.isOnline;
    
    _connectivitySubscription = service.connectionStream.listen((status) {
      _isOnline = status;
      onConnectivityChanged(status);
    });
  }

  void disposeConnectivity() {
    _connectivitySubscription?.cancel();
  }
}
