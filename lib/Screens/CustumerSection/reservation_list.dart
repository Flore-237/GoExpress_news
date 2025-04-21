import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationListScreen extends StatelessWidget {
  final String email;

  const ReservationListScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Réservations',
          style: TextStyle(color: Colors.white), // Titre en blanc
        ),
        backgroundColor: const Color(0xFF3D56F0),
      ),
      body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('reservations')
        .where('email', isEqualTo: email) // Filtrer par e-mail
        .snapshots(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
    }

          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement des réservations.'));
          }

          final reservations = snapshot.data?.docs;

          // Afficher l'email utilisé pour le débogage
          print('Email utilisé pour la requête: $email');
          print(email);

          if (reservations == null || reservations.isEmpty) {
            print(reservations);
            return const Center(child: Text('Vous n\'avez effectué aucune réservation pour le moment.'));
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservationData = reservations[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Réservation pour: ${reservationData['destination']}'),
                  subtitle: Text('Date: ${reservationData['timestamp'].toDate()}'),
                  trailing: Text('Places: ${reservationData['seats']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}