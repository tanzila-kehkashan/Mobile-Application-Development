import 'package:cloud_firestore/cloud_firestore.dart';

class HelpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a help request
  Future<void> submitHelpRequest({
    required String userId,
    required String userEmail,
    required String userName,
    required String subject,
    required String message,
  }) async {
    try {
      await _firestore.collection('help_requests').add({
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'subject': subject,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      throw 'Error submitting help request: $e';
    }
  }

  // Get all help requests (for admin)
  Stream<List<Map<String, dynamic>>> getHelpRequests() {
    return _firestore
        .collection('help_requests')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Mark request as resolved/unresolved
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('help_requests').doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      throw 'Error updating request status: $e';
    }
  }

  // Get pending requests count
  Future<int> getPendingRequestsCount() async {
    try {
      final snapshot = await _firestore
          .collection('help_requests')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
