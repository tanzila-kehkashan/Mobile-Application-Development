import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String eventId;
  final String eventTitle;
  final String eventLocation;
  final DateTime eventDate;
  final String eventStartTime;
  final int numberOfTickets;
  final double pricePerTicket;
  final double totalAmount;
  final String paymentMethod;
  final String bookingStatus; // confirmed, cancelled, completed
  final DateTime bookedAt;
  final String?  qrCode;

  Booking({
    required this.id,
    required this. userId,
    required this.userName,
    required this.eventId,
    required this.eventTitle,
    required this.eventLocation,
    required this.eventDate,
    required this.eventStartTime,
    required this.numberOfTickets,
    required this. pricePerTicket,
    required this.totalAmount,
    required this.paymentMethod,
    required this.bookingStatus,
    required this.bookedAt,
    this.qrCode,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc. id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventLocation: data['eventLocation'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventStartTime: data['eventStartTime'] ?? '',
      numberOfTickets: data['numberOfTickets'] ?? 1,
      pricePerTicket: (data['pricePerTicket'] ??  0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      bookingStatus: data['bookingStatus'] ?? 'confirmed',
      bookedAt: (data['bookedAt'] as Timestamp).toDate(),
      qrCode: data['qrCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventLocation': eventLocation,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventStartTime': eventStartTime,
      'numberOfTickets': numberOfTickets,
      'pricePerTicket': pricePerTicket,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'bookingStatus': bookingStatus,
      'bookedAt': Timestamp.fromDate(bookedAt),
      'qrCode': qrCode,
    };
  }
}