import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for Cloud Firestore operations
/// Handles CRUD operations and real-time data synchronization
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ CREATE OPERATIONS ============

  /// Add a document to a collection with auto-generated ID
  /// Returns the document ID
  Future<String> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = await _firestore.collection(collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  /// Set a document with a specific ID (creates or overwrites)
  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      throw Exception('Failed to set document: $e');
    }
  }

  // ============ READ OPERATIONS ============

  /// Get a single document by ID
  /// Returns null if document doesn't exist
  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .get();
      
      if (docSnapshot.exists) {
        return {
          'id': docSnapshot.id,
          ...?docSnapshot.data(),
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Get all documents from a collection
  Future<List<Map<String, dynamic>>> getCollection({
    required String collectionPath,
  }) async {
    try {
      final querySnapshot = await _firestore.collection(collectionPath).get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

  /// Query documents with filtering
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collectionPath,
    String? orderByField,
    bool descending = false,
    int? limit,
    Map<String, dynamic>? whereConditions,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);

      // Apply where conditions
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // Apply ordering
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to query documents: $e');
    }
  }

  /// Stream of real-time updates for a document
  Stream<Map<String, dynamic>?> streamDocument({
    required String collectionPath,
    required String documentId,
  }) {
    try {
      return _firestore
          .collection(collectionPath)
          .doc(documentId)
          .snapshots()
          .map((docSnapshot) {
        if (docSnapshot.exists) {
          return {
            'id': docSnapshot.id,
            ...?docSnapshot.data(),
          };
        }
        return null;
      });
    } catch (e) {
      throw Exception('Failed to stream document: $e');
    }
  }

  /// Stream of real-time updates for a collection
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collectionPath,
    String? orderByField,
    bool descending = false,
    int? limit,
    Map<String, dynamic>? whereConditions,
  }) {
    try {
      Query query = _firestore.collection(collectionPath);

      // Apply where conditions
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to stream collection: $e');
    }
  }

  // ============ UPDATE OPERATIONS ============

  /// Update specific fields in a document
  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  // ============ DELETE OPERATIONS ============

  /// Delete a document
  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Delete all documents in a collection (use with caution!)
  Future<void> deleteCollection({
    required String collectionPath,
    int batchSize = 500,
  }) async {
    try {
      final collectionRef = _firestore.collection(collectionPath);
      final querySnapshot = await collectionRef.limit(batchSize).get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Recursively delete remaining documents
      if (querySnapshot.docs.length >= batchSize) {
        await deleteCollection(
          collectionPath: collectionPath,
          batchSize: batchSize,
        );
      }
    } catch (e) {
      throw Exception('Failed to delete collection: $e');
    }
  }

  // ============ BATCH OPERATIONS ============

  /// Perform multiple write operations in a batch
  Future<void> batchWrite({
    required List<Map<String, dynamic>> operations,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final type = operation['type'] as String;
        final collectionPath = operation['collectionPath'] as String;
        final documentId = operation['documentId'] as String?;

        final docRef = documentId != null
            ? _firestore.collection(collectionPath).doc(documentId)
            : _firestore.collection(collectionPath).doc();

        switch (type) {
          case 'set':
            batch.set(docRef, operation['data'] as Map<String, dynamic>);
            break;
          case 'update':
            batch.update(docRef, operation['data'] as Map<String, dynamic>);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to perform batch write: $e');
    }
  }
}
