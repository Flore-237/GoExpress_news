import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

class ReservationService {
  final CollectionReference reservationCollection =
  FirebaseFirestore.instance.collection('reservations');


  Future<String> ajouterReservation(Reservation reservation) async {
    try {
      DocumentReference docRef = await reservationCollection.add(reservation.toMap());
      return docRef.id;
    } catch (e) {
      print('Erreur lors de l\'ajout de la réservation: $e');
      throw e;
    }
  }

  // Obtenir toutes les réservations
  Stream<List<Reservation>> getReservations() {
    return reservationCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Mettre à jour une réservation
  Future<void> mettreAJourReservation(Reservation reservation) async {
    try {
      await reservationCollection.doc(reservation.id).update(reservation.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour de la réservation: $e');
      throw e;
    }
  }

  // Supprimer une réservation
  Future<void> supprimerReservation(String id) async {
    try {
      await reservationCollection.doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression de la réservation: $e');
      throw e;
    }
  }
}