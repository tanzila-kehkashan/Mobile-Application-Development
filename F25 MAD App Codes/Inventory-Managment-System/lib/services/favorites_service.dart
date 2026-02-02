import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_service.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Local storage key for guest favorites
  static const String _guestFavoritesKey = 'guest_favorites';

  // In-memory cache for immediate updates
  Set<String> _favoriteIds = {};
  List<Map<String, dynamic>> _favoritesList = [];
  bool _isInitialized = false;

  // Stream controllers for reactive updates
  final _favoriteIdsController = StreamController<Set<String>>.broadcast();
  final _favoritesListController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  String? get _userId => _auth.currentUser?.uid;
  bool get _isLoggedIn => _userId != null;

  // Initialize - must be called before using
  Future<void> init() async {
    if (_isInitialized) return;
    await _loadFavorites();
    _isInitialized = true;
  }

  // Load favorites from storage
  Future<void> _loadFavorites() async {
    if (_isLoggedIn) {
      // Load from Firebase for logged-in users
      try {
        final snapshot = await _favoritesCollection.get();
        _favoriteIds = snapshot.docs.map((doc) => doc.id).toSet();
        _favoritesList = snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      } catch (e) {
        print('Error loading favorites from Firebase: $e');
        _favoriteIds = {};
        _favoritesList = [];
      }
    } else {
      // Load from SharedPreferences for guests
      try {
        final prefs = await SharedPreferences.getInstance();
        final favoritesJson = prefs.getStringList(_guestFavoritesKey) ?? [];
        _favoritesList = favoritesJson
            .map((json) => jsonDecode(json) as Map<String, dynamic>)
            .toList();
        _favoriteIds = _favoritesList
            .map((f) => f['id']?.toString() ?? '')
            .toSet();
      } catch (e) {
        print('Error loading local favorites: $e');
        _favoriteIds = {};
        _favoritesList = [];
      }
    }
    _notifyListeners();
  }

  // Save favorites to local storage (for guests)
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favoritesList
          .map((fav) => jsonEncode(fav))
          .toList();
      await prefs.setStringList(_guestFavoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving local favorites: $e');
    }
  }

  void _notifyListeners() {
    if (!_favoriteIdsController.isClosed) {
      _favoriteIdsController.add(Set.from(_favoriteIds));
    }
    if (!_favoritesListController.isClosed) {
      _favoritesListController.add(List.from(_favoritesList));
    }
  }

  // Get favorites collection reference (for logged-in users)
  CollectionReference<Map<String, dynamic>> get _favoritesCollection {
    return _firestore.collection('users').doc(_userId).collection('favorites');
  }

  // Add product to favorites
  Future<bool> addToFavorites(Product product) async {
    final productId = product.id ?? '';
    if (productId.isEmpty) return false;

    // Update in-memory cache immediately
    _favoriteIds.add(productId);
    final favData = {
      'id': productId,
      'productId': productId,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'quantity': product.quantity,
      'imageUrl': product.imageUrl,
      'addedAt': DateTime.now().toIso8601String(),
    };
    _favoritesList.add(favData);
    _notifyListeners();

    // Save to storage
    if (_isLoggedIn) {
      try {
        await _favoritesCollection.doc(productId).set({
          ...favData,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error saving to Firebase: $e');
      }
    } else {
      await _saveToLocal();
    }

    return true;
  }

  // Remove product from favorites
  Future<bool> removeFromFavorites(String productId) async {
    if (productId.isEmpty) return false;

    // Update in-memory cache immediately
    _favoriteIds.remove(productId);
    _favoritesList.removeWhere((f) => f['id'] == productId);
    _notifyListeners();

    // Save to storage
    if (_isLoggedIn) {
      try {
        await _favoritesCollection.doc(productId).delete();
      } catch (e) {
        print('Error removing from Firebase: $e');
      }
    } else {
      await _saveToLocal();
    }

    return true;
  }

  // Toggle favorite status - returns true if now favorited
  Future<bool> toggleFavorite(Product product) async {
    await init(); // Ensure initialized

    final productId = product.id ?? '';
    if (productId.isEmpty) return false;

    if (_favoriteIds.contains(productId)) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(product);
      return true;
    }
  }

  // Check if product is in favorites (sync for immediate UI)
  bool isFavoriteSync(String productId) {
    return _favoriteIds.contains(productId);
  }

  // Check if product is in favorites (async)
  Future<bool> isFavorite(String productId) async {
    await init();
    return _favoriteIds.contains(productId);
  }

  // Stream of favorite product IDs
  Stream<Set<String>> getFavoriteIdsStream() {
    init(); // Ensure initialized
    return _favoriteIdsController.stream;
  }

  // Get current favorite IDs synchronously
  Set<String> get currentFavoriteIds {
    return Set.from(_favoriteIds);
  }

  // Stream of favorite products
  Stream<List<Map<String, dynamic>>> getFavoritesStream() {
    init(); // Ensure initialized
    return _favoritesListController.stream;
  }

  // Get current favorites list directly
  Future<List<Map<String, dynamic>>> getFavoritesList() async {
    await init();
    return List.from(_favoritesList);
  }

  // Get favorites list synchronously (may be empty if not initialized)
  List<Map<String, dynamic>> get currentFavoritesList {
    return List.from(_favoritesList);
  }

  // Get count of favorites
  int get favoritesCount => _favoriteIds.length;

  // Dispose
  void dispose() {
    _favoriteIdsController.close();
    _favoritesListController.close();
  }
}

// Global instance
final favoritesService = FavoritesService();
