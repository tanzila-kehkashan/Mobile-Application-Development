import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

// UserService provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Users collection reference
final usersCollectionProvider = Provider<CollectionReference>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users');
});

// Stream provider to get user data by userId
final userByIdProvider = StreamProvider. family<Map<String, dynamic>?, String>((ref, userId) {
  if (userId. isEmpty) {
    return Stream.value(null);
  }

  final usersCollection = ref.watch(usersCollectionProvider);

  return usersCollection
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id;
      return data;
    }
    return null;
  });
});

// Future provider to get user data by userId (one-time fetch)
final userByIdFutureProvider = FutureProvider. family<Map<String, dynamic>?, String>((ref, userId) async {
  if (userId.isEmpty) {
    return null;
  }

  final usersCollection = ref.watch(usersCollectionProvider);

  final snapshot = await usersCollection. doc(userId).get();
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String, dynamic>;
    data['id'] = snapshot.id;
    return data;
  }
  return null;
});

// Stream provider to get current user's data
final currentUserDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final currentUser = ref.watch(authStateProvider). value;

  if (currentUser == null) {
    return Stream.value(null);
  }

  final usersCollection = ref.watch(usersCollectionProvider);

  return usersCollection
      . doc(currentUser.uid)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id;
      return data;
    }
    return null;
  });
});