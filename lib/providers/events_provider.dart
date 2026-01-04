import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Events collection reference
final eventsCollectionProvider = Provider<CollectionReference>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('events');
});

// Stream of all events (as List of Maps)
final eventsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final eventsCollection = ref.watch(eventsCollectionProvider);

  return eventsCollection
      .orderBy('date', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }). toList();
  });
});

// Stream of upcoming events only (future dates)
final upcomingEventsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final eventsCollection = ref.watch(eventsCollectionProvider);
  final now = Timestamp.now();

  return eventsCollection
      .where('date', isGreaterThanOrEqualTo: now)
      . orderBy('date', descending: false)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  });
});

// Stream of past events only (past dates)
final pastEventsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final eventsCollection = ref.watch(eventsCollectionProvider);
  final now = Timestamp.now();

  return eventsCollection
      . where('date', isLessThan: now)
      .orderBy('date', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs. map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }). toList();
  });
});

// ✅ FIXED: Get events by category (client-side filtering to avoid composite index)
final eventsByCategoryProvider = StreamProvider. family<List<Map<String, dynamic>>, String>((ref, category) {
  final eventsCollection = ref.watch(eventsCollectionProvider);

  // ✅ For "All", get ALL events (no date filter)
  if (category == 'All') {
    return eventsCollection
        .orderBy('date', descending: false)
        .limit(50) // Increased limit to show more events
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // For specific categories: Get all events and filter client-side
  // This avoids the composite index requirement
  return eventsCollection
      . orderBy('date', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    })
        .where((event) => event['category'] == category)
        .toList();
  });
});

// Get single event by ID
final eventByIdProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, eventId) {
  final eventsCollection = ref.watch(eventsCollectionProvider);

  return eventsCollection
      . doc(eventId)
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

// Get events by organizer ID
final eventsByOrganizerProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, organizerId) {
  final eventsCollection = ref.watch(eventsCollectionProvider);

  return eventsCollection
      .where('organizerId', isEqualTo: organizerId)
      .orderBy('date', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  });
});

// Search events by title
final searchEventsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, searchQuery) {
  final eventsCollection = ref.watch(eventsCollectionProvider);

  if (searchQuery.isEmpty) {
    return Stream.value([]);
  }

  return eventsCollection
      . orderBy('title')
      .startAt([searchQuery])
      . endAt(['$searchQuery\uf8ff'])
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  });
});

// Get nearby events (filtered by New York location for now)
final nearbyEventsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final eventsCollection = ref.watch(eventsCollectionProvider);
  final now = Timestamp.now();

  return eventsCollection
      . where('date', isGreaterThanOrEqualTo: now)
      . orderBy('date', descending: false)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    final allEvents = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    return allEvents.where((event) {
      final address = (event['address'] as String?  ?? '').toLowerCase();
      return address.contains('new york') || address.contains('ny') || address.contains('usa');
    }).toList();
  });
});

// Selected category notifier
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setCategory(String category) {
    state = category;
  }

  void reset() {
    state = 'All';
  }
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(
  SelectedCategoryNotifier. new,
);