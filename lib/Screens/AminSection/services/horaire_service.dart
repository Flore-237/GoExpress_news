import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/horaire.dart';

class HoraireService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> ajouterHoraire(Horaire horaire) async {
    await _firestore.collection('TravelInfo').add({
      'agencyName': horaire.agencyName,
      'departure': horaire.departure,
      'departureDate': horaire.departureDate,
      'destination': horaire.destination,
      'seats': horaire.seats,
      'imageUrl': horaire.imageUrl,
      'time': horaire.time,
    });
  } // -ajouter les numero de bus, heure d'arriver, sur un billet on doit avoir le numero de bus qui vas faire le vovaye
  // - plusieur niveau , le gestionnaire doit affecter le bus a des voyage, - generer les billet different agent avec les logo,
  // -envoyer des mail, sms, payement en ligne,au niveau du payement de billet, envoyer un mail et sms avec les informations du compte. Creer une commande avent de passer au paymenent
  //

  Future<void> mettreAJourHoraire(Horaire horaire) async {
    await _firestore.collection('TravelInfo').doc(horaire.id).update({
      'agencyName': horaire.agencyName,
      'departure': horaire.departure,
      'departureDate': horaire.departureDate,
      'destination': horaire.destination,
      'seats': horaire.seats,
      'imageUrl': horaire.imageUrl,
      'time': horaire.time,
    });
  }

  Future<void> supprimerHoraire(String id) async {
    await _firestore.collection('TravelInfo').doc(id).delete();
  }

  Stream<List<Horaire>> getHoraires() {
    return _firestore.collection('TravelInfo').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Horaire(
          id: doc.id,
          agencyName: doc['agencyName'],
          departure: doc['departure'],
          departureDate: doc['departureDate'],
          destination: doc['destination'],
          seats: doc['seats'],
          imageUrl: doc['imageUrl'],
          time: doc['time'],
        );
      }).toList();
    });
  }
}