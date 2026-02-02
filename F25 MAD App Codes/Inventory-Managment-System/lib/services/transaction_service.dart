import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Transaction type enum
enum TransactionType { sale, purchase }

/// Transaction model class for sales and purchases
class InventoryTransaction {
  final String? id;
  final String productId;
  final String productName;
  final TransactionType type;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? supplierId;
  final String? supplierName;
  final String? customerName;
  final String? notes;
  final DateTime transactionDate;
  final DateTime createdAt;
  final String userId;

  InventoryTransaction({
    this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    double? totalAmount,
    this.supplierId,
    this.supplierName,
    this.customerName,
    this.notes,
    DateTime? transactionDate,
    DateTime? createdAt,
    required this.userId,
  }) : totalAmount = totalAmount ?? (quantity * unitPrice),
       transactionDate = transactionDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  /// Convert Transaction to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'type': type == TransactionType.sale ? 'sale' : 'purchase',
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'customerName': customerName,
      'notes': notes,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  /// Create Transaction from Firestore document
  factory InventoryTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryTransaction(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      type: data['type'] == 'sale'
          ? TransactionType.sale
          : TransactionType.purchase,
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      supplierId: data['supplierId'],
      supplierName: data['supplierName'],
      customerName: data['customerName'],
      notes: data['notes'],
      transactionDate: data['transactionDate'] != null
          ? (data['transactionDate'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }

  /// Check if this is a sale
  bool get isSale => type == TransactionType.sale;

  /// Check if this is a purchase
  bool get isPurchase => type == TransactionType.purchase;
}

/// Transaction service for Firestore operations
class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Transactions collection reference
  CollectionReference<Map<String, dynamic>> get _transactionsCollection =>
      _firestore.collection('transactions');

  /// Products collection reference (for updating quantities)
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  /// Add a new transaction and update product quantity
  Future<String> addTransaction(InventoryTransaction transaction) async {
    try {
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      // Start a batch write
      final batch = _firestore.batch();

      // Add the transaction
      final transactionRef = _transactionsCollection.doc();
      batch.set(transactionRef, transaction.toMap());

      // Update product quantity
      final productRef = _productsCollection.doc(transaction.productId);
      final productDoc = await productRef.get();

      if (productDoc.exists) {
        final currentQuantity = productDoc.data()?['quantity'] ?? 0;
        int newQuantity;

        if (transaction.isSale) {
          // Decrease quantity for sales
          newQuantity = currentQuantity - transaction.quantity;
          if (newQuantity < 0) {
            throw 'Insufficient stock. Available: $currentQuantity';
          }
        } else {
          // Increase quantity for purchases
          newQuantity = currentQuantity + transaction.quantity;
        }

        batch.update(productRef, {'quantity': newQuantity});
      }

      await batch.commit();
      return transactionRef.id;
    } catch (e) {
      throw 'Failed to add transaction: $e';
    }
  }

  /// Get all transactions for current user (Stream)
  Stream<List<InventoryTransaction>> getTransactionsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryTransaction.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get sales transactions only
  Stream<List<InventoryTransaction>> getSalesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'sale')
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryTransaction.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get purchase transactions only
  Stream<List<InventoryTransaction>> getPurchasesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'purchase')
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryTransaction.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get transactions for a specific product
  Stream<List<InventoryTransaction>> getProductTransactionsStream(
    String productId,
  ) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _transactionsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('productId', isEqualTo: productId)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryTransaction.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get total sales amount
  Future<double> getTotalSalesAmount() async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('type', isEqualTo: 'sale')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Get total purchases amount
  Future<double> getTotalPurchasesAmount() async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('type', isEqualTo: 'purchase')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Get transactions count
  Future<Map<String, int>> getTransactionsCounts() async {
    if (currentUserId == null) return {'sales': 0, 'purchases': 0};

    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      int sales = 0;
      int purchases = 0;
      for (var doc in snapshot.docs) {
        if (doc.data()['type'] == 'sale') {
          sales++;
        } else {
          purchases++;
        }
      }
      return {'sales': sales, 'purchases': purchases};
    } catch (e) {
      return {'sales': 0, 'purchases': 0};
    }
  }

  /// Delete a transaction (Note: Does NOT reverse the quantity change)
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }
}

/// Global instance of TransactionService
final transactionService = TransactionService();
