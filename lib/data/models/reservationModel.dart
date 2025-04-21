import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum BookingStatus { pending, confirmed, cancelled }
enum BookingType { standard, vip }
enum PaymentMethod { mobileMoney, orangeMoney, cash }

@immutable
class BookingModel {
  final String id;
  final String userId;
  final String routeId;
  final String agencyId;
  final BookingStatus status;
  final BookingType type;
  final PaymentMethod paymentMethod;
  final DateTime bookingDate;
  final DateTime travelDate;
  final String seatNumber;
  final double totalPrice;
  final String passengerName;
  final String passengerPhone;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.agencyId,
    this.status = BookingStatus.pending,
    this.type = BookingType.standard,
    required this.paymentMethod,
    required this.bookingDate,
    required this.travelDate,
    required this.seatNumber,
    required this.totalPrice,
    required this.passengerName,
    required this.passengerPhone,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      routeId: data['routeId'] ?? '',
      agencyId: data['agencyId'] ?? '',
      status: BookingStatus.values.firstWhere(
            (e) => e.toString() == 'BookingStatus.${data['status'] ?? 'pending'}',
      ),
      type: BookingType.values.firstWhere(
            (e) => e.toString() == 'BookingType.${data['type'] ?? 'standard'}',
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.toString() == 'PaymentMethod.${data['paymentMethod'] ?? 'mobileMoney'}',
      ),
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      travelDate: (data['travelDate'] as Timestamp).toDate(),
      seatNumber: data['seatNumber'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      passengerName: data['passengerName'] ?? '',
      passengerPhone: data['passengerPhone'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'routeId': routeId,
      'agencyId': agencyId,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'bookingDate': bookingDate,
      'travelDate': travelDate,
      'seatNumber': seatNumber,
      'totalPrice': totalPrice,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
    };
  }

  BookingModel copyWith({
    BookingStatus? status,
    BookingType? type,
    PaymentMethod? paymentMethod,
    DateTime? travelDate,
    String? seatNumber,
    double? totalPrice,
    String? passengerName,
    String? passengerPhone,
  }) {
    return BookingModel(
      id: id,
      userId: userId,
      routeId: routeId,
      agencyId: agencyId,
      status: status ?? this.status,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingDate: bookingDate,
      travelDate: travelDate ?? this.travelDate,
      seatNumber: seatNumber ?? this.seatNumber,
      totalPrice: totalPrice ?? this.totalPrice,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
    );
  }
}