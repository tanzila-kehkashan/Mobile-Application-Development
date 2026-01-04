import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search events by title (case-insensitive)
  /// Returns a stream of matching events
  Stream<List<Map<String, dynamic>>> searchEventsByTitle(String query) {
    if (query.trim().isEmpty) {
      return Stream.value([]);
    }

    final lowercaseQuery = query.toLowerCase().trim();

    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      // Client-side filtering for case-insensitive search
      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      })
          .where((event) {
        final title = (event['title'] as String?  ?? '').toLowerCase();
        final location = (event['location'] as String? ?? '').toLowerCase();
        final organizerName = (event['organizerName'] as String? ?? '').toLowerCase();
        final category = (event['category'] as String? ?? '').toLowerCase();

        // Search in multiple fields
        return title.contains(lowercaseQuery) ||
            location.contains(lowercaseQuery) ||
            organizerName.contains(lowercaseQuery) ||
            category. contains(lowercaseQuery);
      })
          .toList();
    });
  }

  /// Search events with filters
  Stream<List<Map<String, dynamic>>> searchEventsWithFilters({
    required String query,
    String? category,
    DateTime? startDate,
    DateTime?  endDate,
    double? minPrice,
    double? maxPrice,
  }) {
    if (query.trim().isEmpty) {
      return Stream.value([]);
    }

    final lowercaseQuery = query.toLowerCase().trim();

    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      var results = snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      })
          .where((event) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        final location = (event['location'] as String? ?? '').toLowerCase();
        final organizerName = (event['organizerName'] as String? ?? '').toLowerCase();

        return title.contains(lowercaseQuery) ||
            location.contains(lowercaseQuery) ||
            organizerName.contains(lowercaseQuery);
      })
          .toList();

      // Apply category filter
      if (category != null && category != 'All') {
        results = results. where((event) => event['category'] == category).toList();
      }

      // Apply date filters
      if (startDate != null) {
        results = results. where((event) {
          final eventDate = (event['date'] as Timestamp).toDate();
          return eventDate. isAfter(startDate) || eventDate.isAtSameMomentAs(startDate);
        }).toList();
      }

      if (endDate != null) {
        results = results.where((event) {
          final eventDate = (event['date'] as Timestamp).toDate();
          return eventDate.isBefore(endDate) || eventDate.isAtSameMomentAs(endDate);
        }).toList();
      }

      // Apply price filters
      if (minPrice != null) {
        results = results.where((event) {
          final price = (event['price'] as num?  ?? 0).toDouble();
          return price >= minPrice;
        }).toList();
      }

      if (maxPrice != null) {
        results = results.where((event) {
          final price = (event['price'] as num? ?? 0).toDouble();
          return price <= maxPrice;
        }).toList();
      }

      return results;
    });
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final lowercaseQuery = query.toLowerCase().trim();

    final snapshot = await _firestore.collection('events').get();

    final suggestions = <String>{};

    for (var doc in snapshot.docs) {
      final title = (doc.data()['title'] as String? ?? '').toLowerCase();
      if (title.contains(lowercaseQuery)) {
        suggestions.add(doc.data()['title'] as String);
      }
    }

    return suggestions. take(5).toList();
  }

  /// Search recent/popular events
  Future<List<Map<String, dynamic>>> getPopularSearches() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('attendees', descending: true)
          .limit(5)
          .get();

      return snapshot.docs. map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting popular searches: $e');
      return [];
    }
  }
}