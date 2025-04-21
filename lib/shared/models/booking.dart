import 'package:cloud_firestore/cloud_firestore.dart';
import 'travel.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }
enum PaymentMethod { mobileMoney, orangeMoney }

class Booking {
  final String id;
  final String userId;
  final String travelId;
  final String agencyId;
  final TravelClass travelClass;
  final DateTime bookingDate;
  final BookingStatus status;
  final PaymentMethod paymentMethod;
  final double amount;
  final Map<String, dynamic> passengerInfo;
  final String? paymentReference;
  final String? ticketNumber;

  Booking({
    required this.id,
    required this.userId,
    required this.travelId,
    required this.agencyId,
    required this.travelClass,
    required this.bookingDate,
    required this.status,
    required this.paymentMethod,
    required this.amount,
    required this.passengerInfo,
    this.paymentReference,
    this.ticketNumber,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      travelId: data['travelId'] ?? '',
      agencyId: data['agencyId'] ?? '',
      travelClass: TravelClass.values.firstWhere(
        (e) => e.toString() == data['travelClass'],
        orElse: () => TravelClass.classic,
      ),
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == data['paymentMethod'],
        orElse: () => PaymentMethod.mobileMoney,
      ),
      amount: (data['amount'] ?? 0).toDouble(),
      passengerInfo: Map<String, dynamic>.from(data['passengerInfo'] ?? {}),
      paymentReference: data['paymentReference'],
      ticketNumber: data['ticketNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'travelId': travelId,
      'agencyId': agencyId,
      'travelClass': travelClass.toString(),
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status.toString(),
      'paymentMethod': paymentMethod.toString(),
      'amount': amount,
      'passengerInfo': passengerInfo,
      'paymentReference': paymentReference,
      'ticketNumber': ticketNumber,
    };
  }

  bool get isPaid => paymentReference != null;
  bool get hasTicket => ticketNumber != null;
  bool get isActive => status == BookingStatus.confirmed || status == BookingStatus.pending;
}
