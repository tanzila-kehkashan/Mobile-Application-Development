import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Product model class
class Product {
  final String? id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String? sku;
  final int minStockLevel;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final String userId;
  final String? supplierName;
  final String? supplierContact;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.sku,
    this.minStockLevel = 10,
    this.description,
    this.imageUrl,
    DateTime? createdAt,
    required this.userId,
    this.supplierName,
    this.supplierContact,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'sku': sku,
      'minStockLevel': minStockLevel,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'supplierName': supplierName,
      'supplierContact': supplierContact,
    };
  }

  /// Create Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      sku: data['sku'],
      minStockLevel: data['minStockLevel'] ?? 10,
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
      supplierName: data['supplierName'],
      supplierContact: data['supplierContact'],
    );
  }

  /// Check if product is low on stock
  bool get isLowStock => quantity <= minStockLevel;

  /// Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? sku,
    int? minStockLevel,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    String? userId,
    String? supplierName,
    String? supplierContact,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sku: sku ?? this.sku,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      supplierName: supplierName ?? this.supplierName,
      supplierContact: supplierContact ?? this.supplierContact,
    );
  }
}

/// Product service for Firestore operations
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Products collection reference
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  /// Add a new product
  Future<String> addProduct(Product product) async {
    try {
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      final docRef = await _productsCollection.add(
        product.copyWith(userId: currentUserId).toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw 'Product ID is required for update';
      }
      await _productsCollection.doc(product.id).update(product.toMap());
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  /// Get all products for current user (Stream)
  Stream<List<Product>> getProductsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _productsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  /// Get all products for current user (Future)
  Future<List<Product>> getProducts() async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await _productsCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Failed to get products: $e';
    }
  }

  /// Get low stock products
  Stream<List<Product>> getLowStockProductsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _productsCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .where((product) => product.isLowStock)
              .toList(),
        );
  }

  /// Get products by category
  Stream<List<Product>> getProductsByCategoryStream(String category) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _productsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  /// Get total stock count
  Future<int> getTotalStockCount() async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _productsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['quantity'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Get total products count
  Future<int> getTotalProductsCount() async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _productsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Update product quantity
  Future<void> updateQuantity(String productId, int newQuantity) async {
    try {
      await _productsCollection.doc(productId).update({
        'quantity': newQuantity,
      });
    } catch (e) {
      throw 'Failed to update quantity: $e';
    }
  }

  /// Search products by name
  Stream<List<Product>> searchProducts(String query) {
    if (currentUserId == null || query.isEmpty) {
      return Stream.value([]);
    }

    // Note: Firestore doesn't support full-text search natively
    // This is a simple prefix search
    return _productsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }
}

/// Global instance of ProductService
final productService = ProductService();
