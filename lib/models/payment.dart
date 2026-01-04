import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String userId;
  final String bookingId;
  final String eventId;
  final double amount;
  final String currency;
  final String paymentMethod; // stripe, paypal, etc.
  final String status; // pending, completed, failed, refunded
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.eventId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      eventId: data['eventId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'pending',
      stripePaymentIntentId: data['stripePaymentIntentId'],
      stripeChargeId: data['stripeChargeId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookingId': bookingId,
      'eventId': eventId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'stripePaymentIntentId': stripePaymentIntentId,
      'stripeChargeId': stripeChargeId,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'metadata': metadata,
    };
  }

  Payment copyWith({
    String? id,
    String? userId,
    String? bookingId,
    String? eventId,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? status,
    String? stripePaymentIntentId,
    String? stripeChargeId,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      eventId: eventId ?? this.eventId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeChargeId: stripeChargeId ?? this.stripeChargeId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
