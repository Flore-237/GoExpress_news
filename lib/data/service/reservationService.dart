import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reservationModel.dart';
import '../models/routeModel.dart';


class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BookingModel?> createBooking(BookingModel booking) async {
    try {
      // Vérifier la disponibilité des sièges
      DocumentReference routeDoc = _firestore.collection('routes').doc(booking.routeId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot routeSnapshot = await transaction.get(routeDoc);
        RouteModel route = RouteModel.fromFirestore(routeSnapshot);

        if (route.availableSeats <= 0) {
          throw Exception('Aucun siège disponible');
        }

        // Mettre à jour le nombre de sièges disponibles
        transaction.update(routeDoc, {
          'availableSeats': route.availableSeats - 1
        });

        // Créer la réservation
        DocumentReference bookingRef = _firestore.collection('bookings').doc();
        transaction.set(bookingRef, booking.toFirestore());
      });

      return booking;
    } catch (e) {
      print('Erreur lors de la création de la réservation : $e');
      return null;
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations : $e');
      return [];
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Récupérer la réservation
        DocumentReference bookingRef = _firestore.collection('bookings').doc(bookingId);
        DocumentSnapshot bookingSnapshot = await transaction.get(bookingRef);
        BookingModel booking = BookingModel.fromFirestore(bookingSnapshot);

        // Mettre à jour le statut de la réservation
        transaction.update(bookingRef, {
          'status': BookingStatus.cancelled.toString().split('.').last
        });

        // Restaurer le nombre de sièges
        DocumentReference routeRef = _firestore.collection('routes').doc(booking.routeId);
        transaction.update(routeRef, {
          'availableSeats': FieldValue.increment(1)
        });
      });

      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation de la réservation : $e');
      return false;
    }
  }

  Future<List<BookingModel>> getAgencyBookings(String agencyId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('bookings')
          .where('agencyId', isEqualTo: agencyId)
          .get();

      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations de l\'agence : $e');
      return [];
    }
  }
}