import 'package:cloud_firestore/cloud_firestore.dart';

enum TravelClass { vip, classic }

class Travel {
  final String id;
  final String agencyId;
  final String departure;
  final String destination;
  final DateTime departureTime;
  final int availableSeatsVIP;
  final int availableSeatsClassic;
  final double priceVIP;
  final double priceClassic;
  final String busNumber;
  final Map<String, dynamic> additionalInfo;

  Travel({
    required this.id,
    required this.agencyId,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.availableSeatsVIP,
    required this.availableSeatsClassic,
    required this.priceVIP,
    required this.priceClassic,
    required this.busNumber,
    this.additionalInfo = const {},
  });

  factory Travel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Travel(
      id: doc.id,
      agencyId: data['agencyId'] ?? '',
      departure: data['departure'] ?? '',
      destination: data['destination'] ?? '',
      departureTime: (data['departureTime'] as Timestamp).toDate(),
      availableSeatsVIP: data['availableSeatsVIP'] ?? 0,
      availableSeatsClassic: data['availableSeatsClassic'] ?? 0,
      priceVIP: (data['priceVIP'] ?? 0).toDouble(),
      priceClassic: (data['priceClassic'] ?? 0).toDouble(),
      busNumber: data['busNumber'] ?? '',
      additionalInfo: Map<String, dynamic>.from(data['additionalInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'agencyId': agencyId,
      'departure': departure,
      'destination': destination,
      'departureTime': Timestamp.fromDate(departureTime),
      'availableSeatsVIP': availableSeatsVIP,
      'availableSeatsClassic': availableSeatsClassic,
      'priceVIP': priceVIP,
      'priceClassic': priceClassic,
      'busNumber': busNumber,
      'additionalInfo': additionalInfo,
    };
  }

  bool hasAvailableSeats(TravelClass travelClass) {
    return travelClass == TravelClass.vip 
        ? availableSeatsVIP > 0 
        : availableSeatsClassic > 0;
  }

  double getPrice(TravelClass travelClass) {
    return travelClass == TravelClass.vip ? priceVIP : priceClassic;
  }
}
