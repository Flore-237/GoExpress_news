import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agence.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAgency(Agency agency) async {
    await _firestore.collection('agences').doc(agency.id).set(agency.toMap());
  }

  String _generateFormattedDates(int daysCount) {
    final now = DateTime.now();
    final nextDays = List.generate(daysCount, (i) => DateTime(now.year, now.month, now.day + i));
    return nextDays.map((date) {
      final weekday = _getFrenchWeekday(date.weekday);
      final month = _getFrenchMonth(date.month);
      return '$weekday, ${date.day.toString().padLeft(2, '0')} $month ${date.year}';
    }).join(', ');
  }

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

  void addBuccaVoyage() {
    final formattedDates = _generateFormattedDates(30);

    // Convertir les données pour correspondre au modèle Agency
    final routesJson = [
      {
        'name': 'Yaoundé - Mvan',
        'contacts': {
          'Réservation VIP': '+237 691 630 293',
          'Réservation Class': '+237 691 629 307',
          'Courrier envoi': '+237 692 957 148',
          'Courrier retrait': '+237 692 957 148',
          'Service de chambre': '+237 680 758 817',
        },
        'schedules': []
      },
    ].map((route) => route.toString()).toList();

    final pricingJson = {
      'Standard': '2000 FCFA',
      'Premium': '5000 FCFA',
    }.toString();

    Agency agency = Agency(
      id: 'bucca_voyage',
      agencyName: 'Bucca Voyage',
      departure: 'Yaoundé (Mvan, Biyem-Assi, Terminus Mimboman, Carriere, Tongolo, Olembe), Douala (Mboppi, Bepanda, Bonaberi, Brazzaville), Ouest (Dschang, Mbouda)',
      departureTime: 'Voir horaires détaillés',
      departureDate: formattedDates,
      seatType: 'Standard, Premium',
      destination: 'Yaoundé, Douala, Ouest, Brazzaville',
      seats: '70',
      imageUrl: 'assets/images/BucaVoyage.jpg',
      name: '',
      logoUrl: 'assets/images/BucaLogo.jpg',
      bannerUrl: 'assets/images/BucaBanner.jpg',
      description: 'Bucca Voyage - Service de transport confortable avec différentes classes de service',
      contactPhone: '691 630 293 / 691 629 307',
      contactEmail: 'contact@buccavoyage.com',
      pricing: pricingJson, // Converti en String
      routes: routesJson,   // Converti en List<String>
    );

    addAgency(agency);
  }

  void addGeneralExpressVoyage() {
    final formattedDates = _generateFormattedDates(30);

    final pricingJson = {
      'Classique': '3000 FCFA',
      'VIP': '5000 FCFA',
    }.toString();

    Agency agency = Agency(
      id: 'general_express_voyage',
      agencyName: 'General Express Voyage',
      departure: 'Baffoussam, Yaoundé(Biyem-assi), Yaoundé(Mvan), Yaoundé(Terminus Mimboman), Douala(Mboppi), Douala(Bepanda), Dschang, Mbouda',
      departureTime: '01h30, 03H00, 04H00, 05H00, 06H30, 08H30, 10H00, 11H00, 12H00, 13H00, 14H00, 15H30, 17H00, 19H00',
      departureDate: formattedDates,
      seatType: 'Classique, VIP',
      destination: 'Baffoussam, Yaoundé, Douala, Dschang, Mbouda',
      seats: '70',
      imageUrl: 'assets/images/GeneraleExpress.png',
      name: '',
      logoUrl: 'assets/images/generaleLogo.jpg',
      bannerUrl: 'assets/images/generaleBanner.jpg',
      description: 'General Express Voyage, le plaisir de voyager',
      contactPhone: '676052134 / 699221455',
      contactEmail: 'generalexpres3@gmail.com',
      routes: [], // Liste vide de String
      pricing: pricingJson, // Converti en String
    );

    addAgency(agency);
  }

  void addTouristiqueExpress() {
    final formattedDates = _generateFormattedDates(30);

    // Convertir les données pour correspondre au modèle Agency
    final routesJson = [
      {
        'name': 'Yaoundé (Ngoa Ekélé) - Douala',
        'contacts': {
          'Réservation VIP': '+237 677 89 45 21',
          'Réservation Classique': '+237 699 54 32 10',
        },
        'schedules': [
          {'time': '05:00', 'type': 'Classique', 'price': '2500 FCFA'},
          {'time': '06:30', 'type': 'VIP', 'price': '4000 FCFA'},
          {'time': '08:00', 'type': 'Classique', 'price': '2500 FCFA'},
          {'time': '10:00', 'type': 'VVIP', 'price': '6000 FCFA'},
        ]
      },
      {
        'name': 'Douala (Bonabéri) - Yaoundé',
        'contacts': {
          'Réservation VVIP': '+237 677 89 45 21',
          'Réservation Standard': '+237 699 54 32 10',
        },
        'schedules': [
          {'time': '06:00', 'type': 'VIP', 'price': '4000 FCFA'},
          {'time': '08:30', 'type': 'Classique', 'price': '2500 FCFA'},
        ]
      },
    ].map((route) => route.toString()).toList();

    final pricingJson = {
      'Classique': '2500 FCFA',
      'VIP': '4000 FCFA',
      'VVIP': '6000 FCFA',
    }.toString();

    Agency agency = Agency(
      id: 'touristique_express',
      agencyName: 'Touristique Express',
      departure: 'Yaoundé (Ngoa Ekélé, Mvan), Douala (Bonabéri, Ndokotti)',
      departureTime: '05H00, 06H30, 08H00, 10H00, 12H00, 14H00, 16H00, 18H00',
      departureDate: formattedDates,
      seatType: 'Classique, VIP, VVIP',
      destination: 'Yaoundé, Douala',
      seats: '70',
      imageUrl: 'assets/images/touristique_express.png',
      name: '',
      logoUrl: 'assets/images/touristique_logo.jpg',
      bannerUrl: 'assets/images/touristique_banner.jpg',
      description: 'Touristique Express - Voyagez avec confort et sécurité',
      contactPhone: '677 89 45 21 / 699 54 32 10',
      contactEmail: 'contact@touristiqueexpress.com',
      pricing: pricingJson, // Converti en String
      routes: routesJson,   // Converti en List<String>
    );

    addAgency(agency);
  }
}