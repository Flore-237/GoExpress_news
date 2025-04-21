import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class RouteModel {
  final String id;
  final String agencyId;
  final String departure;
  final String destination;
  final List<String> departureTimes; // Liste des horaires de départ
  final double price;
  final int availableSeats;
  final DateTime departureDate;
  final Duration estimatedTravelTime;
  final DateTime departureTime; // Ajout de la propriété departureTime
  final bool isVipRoute;         // Ajout de la propriété isVipRoute

  const RouteModel({
    required this.id,
    required this.agencyId,
    required this.departure,
    required this.destination,
    required this.departureTimes,
    required this.price,
    required this.availableSeats,
    required this.departureDate,
    required this.estimatedTravelTime,
    required this.departureTime, // Ajout dans le constructeur
    required this.isVipRoute,     // Ajout dans le constructeur
  });

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RouteModel(
      id: doc.id,
      agencyId: data['agencyId'] ?? '',
      departure: data['departure'] ?? '',
      destination: data['destination'] ?? '',
      departureTimes: List<String>.from(data['departureTimes'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      availableSeats: data['availableSeats'] ?? 0,
      departureDate: (data['departureDate'] as Timestamp).toDate(),
      estimatedTravelTime: Duration(minutes: data['estimatedTravelTime'] ?? 0),
      departureTime: (data['departureTime'] as Timestamp).toDate(), // Ajout de la conversion pour departureTime
      isVipRoute: data['isVipRoute'] ?? false, // Récupération de la valeur pour isVipRoute
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'agencyId': agencyId,
      'departure': departure,
      'destination': destination,
      'departureTimes': departureTimes,
      'price': price,
      'availableSeats': availableSeats,
      'departureDate': departureDate,
      'estimatedTravelTime': estimatedTravelTime.inMinutes,
      'departureTime': departureTime, // Ajout pour sauvegarder departureTime
      'isVipRoute': isVipRoute,         // Ajout pour sauvegarder isVipRoute
    };
  }

  RouteModel copyWith({
    String? departure,
    String? destination,
    List<String>? departureTimes,
    double? price,
    int? availableSeats,
    DateTime? departureDate,
    Duration? estimatedTravelTime,
    DateTime? departureTime, // Ajout pour le copyWith
    bool? isVipRoute,         // Ajout pour le copyWith
    required String id,
  }) {
    return RouteModel(
      id: id,
      agencyId: agencyId,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      departureTimes: departureTimes ?? this.departureTimes,
      price: price ?? this.price,
      availableSeats: availableSeats ?? this.availableSeats,
      departureDate: departureDate ?? this.departureDate,
      estimatedTravelTime: estimatedTravelTime ?? this.estimatedTravelTime,
      departureTime: departureTime ?? this.departureTime, // Ajout pour le copyWith
      isVipRoute: isVipRoute ?? this.isVipRoute,           // Ajout pour le copyWith
    );
  }
}