import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthodes pour formater les dates en français
  String _getFrenchWeekday(int weekday) {
    const weekdays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return weekdays[weekday - 1];
  }

  String _getFrenchMonth(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  // Générer des dates formatées
  List<String> _generateFormattedDates(int days) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      final date = now.add(Duration(days: index));
      return '${_getFrenchWeekday(date.weekday)} ${date.day} ${_getFrenchMonth(date.month)} ${date.year}';
    });
  }

  // Initialiser toutes les collections
  Future<void> initializeAllCollections() async {
    print('Début initialisation des collections...');
    await _createEmptyCollections();
    await _verifyCoreCollections();
    await addGeneralExpressVoyage();
    await _initHoraires();
    print('Toutes les collections ont été initialisées avec succès!');
  }

  Future<void> _initHoraires() async {
    try {
      await _firestore.collection('horaires').doc('modele_par_defaut').set({
        'lundi_ouvert': true,
        'lundi_ouverture': '08:00',
        'lundi_fermeture': '18:00',
        'mardi_ouvert': true,
        'mardi_ouverture': '08:00',
        'mardi_fermeture': '18:00',
        'mercredi_ouvert': true,
        'mercredi_ouverture': '08:00',
        'mercredi_fermeture': '18:00',
        'jeudi_ouvert': true,
        'jeudi_ouverture': '08:00',
        'jeudi_fermeture': '18:00',
        'vendredi_ouvert': true,
        'vendredi_ouverture': '08:00',
        'vendredi_fermeture': '18:00',
        'samedi_ouvert': false,
        'dimanche_ouvert': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Collection horaires initialisée avec modèle par défaut');
    } catch (e) {
      print('Erreur initialisation horaires: ${e.toString()}');
    }
  }

  Future<void> _verifyCoreCollections() async {
    final requiredCollections = [
      'administrateurs',
      'agences',
      'avis',
      'notifications',
      'paiements',
      'promotions',
      'reservations',
      'tickets',
      'users',
      'horaires',
      'voyages',
      'itineraires'
    ];

    for (final col in requiredCollections) {
      try {
        final snap = await _firestore.collection(col).limit(1).get();
        if (snap.docs.isEmpty) {
          await _firestore.collection(col).doc('init').set({
            'verifiedAt': FieldValue.serverTimestamp(),
            'status': 'active'
          });
          print('Collection $col vérifiée et initialisée');
        }
      } catch (e) {
        print('ERREUR vérification $col: ${e.toString()}');
      }
    }
  }

  Future<void> _createEmptyCollections() async {
    final mainCollections = [
      'administrateurs',
      'agences',
      'avis',
      'notifications',
      'paiements',
      'promotions',
      'reservations',
      'tickets',
      'users',
      'horaires',
      'voyages',
      'itineraires'
    ];

    for (final collection in mainCollections) {
      try {
        await _firestore.collection(collection).doc('structure_init').set({
          'createdAt': FieldValue.serverTimestamp(),
          'purpose': 'Initialisation collection'
        });
        print('Collection $collection initialisée');
      } catch (e) {
        print('Erreur initialisation $collection: ${e.toString()}');
      }
    }
  }

  Future<void> addGeneralExpressVoyage() async {
    final formattedDates = _generateFormattedDates(30);

    final departures = ['Baffoussam', 'Yaoundé', 'Douala', 'Dschang', 'Mbouda'];
    final destinations = ['Baffoussam', 'Yaoundé', 'Douala', 'Dschang', 'Mbouda'];

    final pricingJson = {
      'Classique': '5000 FCFA',
      'VIP': '6000 FCFA',
    };

    final agencyData = {
      'id': 'general_express_voyage',
      'nom': 'General Express Voyage',
      'logo': 'assets/images/generaleLogo.jpg',
      'contact': 'Service Client General Express',
      'email': 'generalexpres3@gmail.com',
      'telephone': '676052134 / 699221455',
      'adresse': 'Yaoundé, Biyem-assi',
      'description': 'General Express Voyage, le plaisir de voyager',
      'departures': departures,
      'destinations': destinations,
      'departureDates': formattedDates,
      'departureTimes': '10h',
      'seatTypes': 'Classique, VIP',
      'totalSeats': 70,
      'imageUrl': 'assets/images/GeneraleExpress.png',
      'bannerUrl': 'assets/images/generaleBanner.jpg',
      'pricing': pricingJson,
      'routes': [],
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('agences').doc('general_express_voyage').set(agencyData);
      await _addGeneralExpressItineraries();
      await _addGeneralExpressVoyages();
      print('Données General Express ajoutées avec succès');
    } catch (e) {
      print('Erreur ajout General Express: ${e.toString()}');
    }
  }

  Future<void> _addGeneralExpressItineraries() async {
    final now = DateTime.now();

    try {
      final oldItineraries = await _firestore.collection('itineraires')
          .where('agenceId', isEqualTo: 'general_express_voyage')
          .get();

      for (var doc in oldItineraries.docs) {
        await doc.reference.delete();
      }

      final itineraries = [
        {
          'id': 'general_douala_yaounde_${now.millisecondsSinceEpoch}',
          'agenceId': 'general_express_voyage',
          'departure': 'Douala',
          'destination': 'Yaoundé',
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'general_bafoussam_douala_${now.millisecondsSinceEpoch}',
          'agenceId': 'general_express_voyage',
          'departure': 'Bafoussam',
          'destination': 'Douala',
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'general_yaounde_bafoussam_${now.millisecondsSinceEpoch}',
          'agenceId': 'general_express_voyage',
          'departure': 'Yaoundé',
          'destination': 'Bafoussam',
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _firestore.batch();
      for (var itinerary in itineraries) {
        final docRef = _firestore.collection('itineraires').doc(itinerary['id'] as String);
        batch.set(docRef, itinerary);
      }
      await batch.commit();

    } catch (e) {
      print('Erreur ajout itinéraires General Express: ${e.toString()}');
      throw e;
    }
  }

  Future<void> _addGeneralExpressVoyages() async {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {
      final batch = _firestore.batch();

      // Récupérer les itinéraires pour obtenir les infos de départ/destination
      final itineraries = await _firestore.collection('itineraires')
          .where('agenceId', isEqualTo: 'general_express_voyage')
          .get();

      // Créer un map pour accéder facilement aux itinéraires
      final itineraryMap = { for (var doc in itineraries.docs) doc.id : doc.data() };

      final voyage1 = _firestore.collection('voyages').doc();
      final itineraire1 = itineraryMap['general_douala_yaounde_${now.millisecondsSinceEpoch}'];
      batch.set(voyage1, {
        'itineraireId': 'general_douala_yaounde',
        'agenceId': 'general_express_voyage',
        'departure': itineraire1?['departure'] ?? 'Douala',
        'destination': itineraire1?['destination'] ?? 'Yaoundé',
        'nomAgence': 'General Express Voyage',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '06h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '09h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 70,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 20,
        'numeroVoyage': 'GENERAL-${now.millisecondsSinceEpoch}',
        'statut': 'programmé',
        'chauffeur': 'Jean Fotso',
        'immatriculation': 'CE 1234 GX',
        'numeroBus': 'G01',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final voyage2 = _firestore.collection('voyages').doc();
      final itineraire2 = itineraryMap['general_bafoussam_douala_${now.millisecondsSinceEpoch}'];
      batch.set(voyage2, {
        'itineraireId': 'general_bafoussam_douala',
        'agenceId': 'general_express_voyage',
        'departure': itineraire2?['departure'] ?? 'Bafoussam',
        'destination': itineraire2?['destination'] ?? 'Douala',
        'nomAgence': 'General Express Voyage',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '07h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '10h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 70,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 30,
        'numeroVoyage': 'GENERAL-${now.millisecondsSinceEpoch + 1}',
        'statut': 'programmé',
        'chauffeur': 'Paul Nganhou',
        'immatriculation': 'CE 5678 GX',
        'numeroBus': 'G02',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final voyage3 = _firestore.collection('voyages').doc();
      final itineraire3 = itineraryMap['general_yaounde_bafoussam_${now.millisecondsSinceEpoch}'];
      batch.set(voyage3, {
        'itineraireId': 'general_yaounde_bafoussam',
        'agenceId': 'general_express_voyage',
        'departure': itineraire3?['departure'] ?? 'Yaoundé',
        'destination': itineraire3?['destination'] ?? 'Bafoussam',
        'nomAgence': 'General Express Voyage',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '08h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '11h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 70,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 30,
        'numeroVoyage': 'GENERAL-${now.millisecondsSinceEpoch + 2}',
        'statut': 'programmé',
        'chauffeur': 'Marc Nganga',
        'immatriculation': 'CE 4321 GX',
        'numeroBus': 'G03',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('Voyages General Express ajoutés avec succès');

    } catch (e) {
      print('Erreur ajout voyages General Express: ${e.toString()}');
      throw e;
    }
  }


  Future<void> _addBuccaVoyages() async {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {
      final batch = _firestore.batch();


      final itineraries = await _firestore.collection('itineraires')
          .where('agenceId', isEqualTo: 'bucca_voyage')
          .get();

      final itineraryMap = { for (var doc in itineraries.docs) doc.id : doc.data() };

      final voyage1 = _firestore.collection('voyages').doc();
      final itineraire1 = itineraryMap['bucca_douala_yaounde_${now.millisecondsSinceEpoch}'];
      batch.set(voyage1, {
        'itineraireId': 'bucca_douala_yaounde',
        'agenceId': 'bucca_voyage',
        'departure': itineraire1?['departure'] ?? 'Douala',
        'destination': itineraire1?['destination'] ?? 'Yaoundé',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '05h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '08h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 70,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 20,
        'numeroVoyage': 'BUCCA-${now.millisecondsSinceEpoch}',
        'statut': 'programmé',
        'chauffeur': 'Jean Mbarga',
        'immatriculation': 'CE 1234 AX',
        'numeroBus': 'B01',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final voyage2 = _firestore.collection('voyages').doc();
      final itineraire2 = itineraryMap['bucca_douala_brazzaville_${now.millisecondsSinceEpoch}'];
      batch.set(voyage2, {
        'itineraireId': 'bucca_douala_brazzaville',
        'agenceId': 'bucca_voyage',
        'departure': itineraire2?['departure'] ?? 'Douala',
        'destination': itineraire2?['destination'] ?? 'Brazzaville',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '06h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 2))),
        'heureArriveeEstimee': '12h00',
        'prixClassique': 15000,
        'prixVIP': 20000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 70,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 30,
        'numeroVoyage': 'BUCCA-${now.millisecondsSinceEpoch + 1}',
        'statut': 'programmé',
        'chauffeur': 'Paul Nganhou',
        'immatriculation': 'CE 5678 BX',
        'numeroBus': 'B02',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final voyage3 = _firestore.collection('voyages').doc();
      final itineraire3 = itineraryMap['bucca_douala_bafoussam_${now.millisecondsSinceEpoch}'];
      batch.set(voyage3, {
        'itineraireId': 'bucca_douala_bafoussam',
        'agenceId': 'bucca_voyage',
        'departure': itineraire3?['departure'] ?? 'Douala',
        'destination': itineraire3?['destination'] ?? 'Bafoussam',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '07h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '10h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 70,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 30,
        'numeroVoyage': 'BUCCA-${now.millisecondsSinceEpoch + 2}',
        'statut': 'programmé',
        'chauffeur': 'Pierre Ndam',
        'immatriculation': 'CE 1111 BX',
        'numeroBus': 'B03',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('Voyages Bucca ajoutés avec succès');

    } catch (e) {
      print('Erreur ajout voyages Bucca: ${e.toString()}');
      throw e;
    }
  }

  Future<void> _addTouristiqueVoyages() async {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {
      final batch = _firestore.batch();


      final itineraries = await _firestore.collection('itineraires')
          .where('agenceId', isEqualTo: 'touristique_express')
          .get();

      final itineraryMap = { for (var doc in itineraries.docs) doc.id : doc.data() };

      final voyage1 = _firestore.collection('voyages').doc();
      final itineraire1 = itineraryMap['touristique_douala_yaounde_${now.millisecondsSinceEpoch}'];
      batch.set(voyage1, {
        'itineraireId': 'touristique_douala_yaounde',
        'agenceId': 'touristique_express',
        'departure': itineraire1?['departure'] ?? 'Douala',
        'destination': itineraire1?['destination'] ?? 'Yaoundé',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '05h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '08h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 40,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 20,
        'numeroVoyage': 'TOURISTIQUE-${now.millisecondsSinceEpoch}',
        'statut': 'programmé',
        'chauffeur': 'Pierre Ndam',
        'immatriculation': 'CE 1111 TX',
        'numeroBus': 'T01',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final voyage2 = _firestore.collection('voyages').doc();
      final itineraire2 = itineraryMap['touristique_bafoussam_douala_${now.millisecondsSinceEpoch}'];
      batch.set(voyage2, {
        'itineraireId': 'touristique_bafoussam_douala',
        'agenceId': 'touristique_express',
        'departure': itineraire2?['departure'] ?? 'Bafoussam',
        'destination': itineraire2?['destination'] ?? 'Douala',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '06h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '09h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 40,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 20,
        'numeroVoyage': 'TOURISTIQUE-${now.millisecondsSinceEpoch + 1}',
        'statut': 'programmé',
        'chauffeur': 'Jean Fotso',
        'immatriculation': 'CE 2222 TX',
        'numeroBus': 'T02',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final voyage3 = _firestore.collection('voyages').doc();
      final itineraire3 = itineraryMap['touristique_yaounde_douala_${now.millisecondsSinceEpoch}'];
      batch.set(voyage3, {
        'itineraireId': 'touristique_yaounde_douala',
        'agenceId': 'touristique_express',
        'departure': itineraire3?['departure'] ?? 'Yaoundé',
        'destination': itineraire3?['destination'] ?? 'Douala',
        'dateDepart': dateFormat.format(now.add(Duration(days: 1))),
        'heureDepart': '07h00',
        'dateArriveeEstimee': dateFormat.format(now.add(Duration(days: 1))),
        'heureArriveeEstimee': '10h00',
        'prixClassique': 5000,
        'prixVIP': 7000,
        'placesClassiqueTotal': 70,
        'placesClassiqueDisponibles': 40,
        'placesVIPTotal': 70,
        'placesVIPDisponibles': 20,
        'numeroVoyage': 'TOURISTIQUE-${now.millisecondsSinceEpoch + 2}',
        'statut': 'programmé',
        'chauffeur': 'Marc Nganga',
        'immatriculation': 'CE 3333 TX',
        'numeroBus': 'T03',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('Voyages Touristique ajoutés avec succès');

    } catch (e) {
      print('Erreur ajout voyages Touristique: ${e.toString()}');
      throw e;
    }
  }


}