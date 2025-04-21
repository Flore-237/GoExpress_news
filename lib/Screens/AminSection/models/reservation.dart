import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  String id;
  String clientName;
  String clientEmail;
  String horaireId;
  String nombrePlaces; // Changer en String
  DateTime dateReservation;
  String statut;

  Reservation({
    this.id = '',
    required this.clientName,
    required this.clientEmail,
    required this.horaireId,
    required this.nombrePlaces, // En tant que String
    required this.dateReservation,
    this.statut = 'En attente',
  });

  // Convertir de Firestore à Reservation
  factory Reservation.fromMap(Map<String, dynamic> data, String id) {
    return Reservation(
      id: id,
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      horaireId: data['horaireId'] ?? '',
      nombrePlaces: data['nombrePlaces']?.toString() ?? '0',
      dateReservation: (data['dateReservation'] as Timestamp).toDate(),
      statut: data['statut'] ?? 'En attente',
    );
  }

  // Convertir de Reservation à Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'clientEmail': clientEmail,
      'horaireId': horaireId,
      'nombrePlaces': nombrePlaces, // Conserve en tant que String
      'dateReservation': Timestamp.fromDate(dateReservation),
      'statut': statut,
    };
  }
}