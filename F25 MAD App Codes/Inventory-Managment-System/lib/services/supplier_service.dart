import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Supplier model class
class Supplier {
  final String? id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final List<String> suppliedProducts; // List of product categories or names
  final String? notes;
  final DateTime createdAt;
  final String userId;

  Supplier({
    this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    this.address = '',
    this.suppliedProducts = const [],
    this.notes,
    DateTime? createdAt,
    required this.userId,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Supplier to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'suppliedProducts': suppliedProducts,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  /// Create Supplier from Firestore document
  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      name: data['name'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      suppliedProducts: List<String>.from(data['suppliedProducts'] ?? []),
      notes: data['notes'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }

  /// Create a copy with updated fields
  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    List<String>? suppliedProducts,
    String? notes,
    DateTime? createdAt,
    String? userId,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      suppliedProducts: suppliedProducts ?? this.suppliedProducts,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}

/// Supplier service for Firestore operations
class SupplierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Suppliers collection reference
  CollectionReference<Map<String, dynamic>> get _suppliersCollection =>
      _firestore.collection('suppliers');

  /// Add a new supplier
  Future<String> addSupplier(Supplier supplier) async {
    try {
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      final docRef = await _suppliersCollection.add(
        supplier.copyWith(userId: currentUserId).toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw 'Failed to add supplier: $e';
    }
  }

  /// Update an existing supplier
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      if (supplier.id == null) {
        throw 'Supplier ID is required for update';
      }
      await _suppliersCollection.doc(supplier.id).update(supplier.toMap());
    } catch (e) {
      throw 'Failed to update supplier: $e';
    }
  }

  /// Delete a supplier
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _suppliersCollection.doc(supplierId).delete();
    } catch (e) {
      throw 'Failed to delete supplier: $e';
    }
  }

  /// Get all suppliers for current user (Stream)
  Stream<List<Supplier>> getSuppliersStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _suppliersCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Supplier.fromFirestore(doc)).toList(),
        );
  }

  /// Get all suppliers for current user (Future)
  Future<List<Supplier>> getSuppliers() async {
    if (currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await _suppliersCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Supplier.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Failed to get suppliers: $e';
    }
  }

  /// Get supplier by ID
  Future<Supplier?> getSupplierById(String supplierId) async {
    try {
      final doc = await _suppliersCollection.doc(supplierId).get();
      if (doc.exists) {
        return Supplier.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get supplier: $e';
    }
  }

  /// Search suppliers by name
  Stream<List<Supplier>> searchSuppliers(String query) {
    if (currentUserId == null || query.isEmpty) {
      return Stream.value([]);
    }

    return _suppliersCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Supplier.fromFirestore(doc))
              .where(
                (supplier) =>
                    supplier.name.toLowerCase().contains(query.toLowerCase()) ||
                    supplier.contactPerson.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList(),
        );
  }

  /// Get suppliers count
  Future<int> getSuppliersCount() async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _suppliersCollection
          .where('userId', isEqualTo: currentUserId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}

/// Global instance of SupplierService
final supplierService = SupplierService();
