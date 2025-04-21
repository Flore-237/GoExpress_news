import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum TripStatus { scheduled, boarding, inProgress, completed, cancelled }

enum VehicleType { bus, minibus, van, car }

@immutable
class TripModel {
  final String id;
  final String agencyId;
  final String routeId;
  final String vehicleId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final VehicleType vehicleType;
  final TripStatus status;
  final int availableSeats;
  final List<String> bookedSeats;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TripModel({
    required this.id,
    required this.agencyId,
    required this.routeId,
    required this.vehicleId,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    this.vehicleType = VehicleType.bus,
    this.status = TripStatus.scheduled,
    required this.availableSeats,
    this.bookedSeats = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      agencyId: data['agencyId'] ?? '',
      routeId: data['routeId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      departureTime: (data['departureTime'] as Timestamp).toDate(),
      arrivalTime: (data['arrivalTime'] as Timestamp).toDate(),
      price: (data['price'] as num).toDouble(),
      vehicleType: VehicleType.values.firstWhere(
            (e) => e.toString() == 'VehicleType.${data['vehicleType'] ?? 'bus'}',
        orElse: () => VehicleType.bus,
      ),
      status: TripStatus.values.firstWhere(
            (e) => e.toString() == 'TripStatus.${data['status'] ?? 'scheduled'}',
        orElse: () => TripStatus.scheduled,
      ),
      availableSeats: data['availableSeats'] ?? 0,
      bookedSeats: List<String>.from(data['bookedSeats'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'agencyId': agencyId,
      'routeId': routeId,
      'vehicleId': vehicleId,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
      'vehicleType': vehicleType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TripModel copyWith({
    String? agencyId,
    String? routeId,
    String? vehicleId,
    DateTime? departureTime,
    DateTime? arrivalTime,
    double? price,
    VehicleType? vehicleType,
    TripStatus? status,
    int? availableSeats,
    List<String>? bookedSeats,
    DateTime? updatedAt,
    required String id,
  }) {
    return TripModel(
      id: id,
      agencyId: agencyId ?? this.agencyId,
      routeId: routeId ?? this.routeId,
      vehicleId: vehicleId ?? this.vehicleId,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      price: price ?? this.price,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      availableSeats: availableSeats ?? this.availableSeats,
      bookedSeats: bookedSeats ?? this.bookedSeats,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isAvailable => status == TripStatus.scheduled;
  bool get isFull => availableSeats <= 0;
  Duration get duration => arrivalTime.difference(departureTime);

  // Format duration as "Xh Ym" string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }


  String get departure => departureTime.toIso8601String();
  String get destination => 'Destination pour le trajet';
  String get busType => vehicleType.toString().split('.').last;
  bool get isVipRoute => vehicleType == VehicleType.bus && price > 10000;
}