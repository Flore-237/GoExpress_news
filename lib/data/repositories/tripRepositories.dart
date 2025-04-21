import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticketModel.dart';


class TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TripModel?> createTrip(TripModel trip) async {
    try {
      final docRef = await _firestore.collection('trips').add(trip.toFirestore());
      return trip.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating trip: $e');
      return null;
    }
  }

  Future<List<TripModel>> getTripsByAgency(String agencyId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('agencyId', isEqualTo: agencyId)
          .get();

      return snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching agency trips: $e');
      return [];
    }
  }

  Future<List<TripModel>> getUpcomingTrips({
    int limit = 10,
    String? agencyId,
  }) async {
    try {
      Query query = _firestore
          .collection('trips')
          .where('departureTime', isGreaterThan: DateTime.now())
          .orderBy('departureTime')
          .limit(limit);

      if (agencyId != null) {
        query = query.where('agencyId', isEqualTo: agencyId);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching upcoming trips: $e');
      return [];
    }
  }

  Future<bool> updateTripStatus(String tripId, TripStatus status) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating trip status: $e');
      return false;
    }
  }

  Future<bool> bookSeat(String tripId, String seatNumber) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'bookedSeats': FieldValue.arrayUnion([seatNumber]),
        'availableSeats': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error booking seat: $e');
      return false;
    }
  }

  Stream<List<TripModel>> tripsStreamByRoute(String routeId) {
    return _firestore
        .collection('trips')
        .where('routeId', isEqualTo: routeId)
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TripModel.fromFirestore(doc))
        .toList());
  }
}