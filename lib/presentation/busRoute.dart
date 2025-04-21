import 'package:busexpress/data/models/ticketModel.dart';
import '../data/models/routeModel.dart';

class BusRoute {
  final String departure;
  final String destination;
  final DateTime departureTime;
  final int availableSeats;
  final double price;
  final bool isVipRoute;

  BusRoute({
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.price,
    required this.isVipRoute, // Initialisez isVipRoute dans le constructeur
  });

  // Méthode pour convertir RouteModel en BusRoute
  factory BusRoute.fromRouteModel(RouteModel model) {
    return BusRoute(
      departure: model.departure,
      destination: model.destination,
      departureTime: model.departureDate,  // Remplacez departureTime par departureDate
      availableSeats: model.availableSeats,
      price: model.price,
      isVipRoute: model.isVipRoute,
    );
  }

  // Méthode pour convertir TripModel en BusRoute
  factory BusRoute.fromTripModel(TripModel trip) {
    return BusRoute(
      departure: trip.departure,
      destination: trip.destination,
      departureTime: trip.departureTime,
      availableSeats: trip.availableSeats,
      price: trip.price,
      isVipRoute: trip.isVipRoute,
    );
  }
}