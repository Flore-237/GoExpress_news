import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_express/Screens/travel_details_screen.dart';

class ReservationScreen extends StatelessWidget {
  final TravelDetails travelDetails;
  final String selectedCategory;

  const ReservationScreen({
    Key? key,
    required this.travelDetails,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController contactController = TextEditingController();
    final TextEditingController seatsController = TextEditingController();

    final int selectedPrice = selectedCategory == 'VIP'
        ? travelDetails.vipPrice
        : travelDetails.regularPrice;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Informations du billet',
          style: AppTextStyles.title,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Détails du voyage sélectionné
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Détails du voyage',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 12),
                  DetailRow(label: 'Agence', value: travelDetails.agency),
                  DetailRow(label: 'Destination', value: travelDetails.destination),
                  DetailRow(label: 'Lieu de départ', value: travelDetails.departurePlace),
                  DetailRow(label: 'Catégorie', value: selectedCategory),
                  DetailRow(label: 'Prix unitaire', value: 'FCFA ${selectedPrice.toString()}'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Formulaire de réservation
            const Text(
              'Informations personnelles',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Noms & Prénoms',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Adresse email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(
                labelText: 'Contact',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: seatsController,
              decoration: InputDecoration(
                labelText: 'Nombre de places (max: ${travelDetails.availableSeats})',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Prix total (calculé dynamiquement)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: seatsController,
              builder: (context, value, child) {
                final seats = int.tryParse(value.text) ?? 0;
                final totalPrice = seats * selectedPrice;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Prix total:', style: AppTextStyles.label),
                      Text(
                        'FCFA ${totalPrice.toString()}',
                        style: AppTextStyles.price.copyWith(
                          color: AppColors.primary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Bouton de confirmation
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    seatsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final requestedSeats = int.tryParse(seatsController.text) ?? 0;
                if (requestedSeats <= 0 || requestedSeats > travelDetails.availableSeats) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nombre de places invalide'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Stocker la réservation dans Firestore
                try {
                  await FirebaseFirestore.instance.collection('reservations').add({
                    'name': nameController.text,
                    'email': emailController.text,
                    'contact': contactController.text,
                    'seats': requestedSeats,
                    'category': selectedCategory,
                    'pricePerSeat': selectedPrice,
                    'totalPrice': requestedSeats * selectedPrice,
                    'agency': travelDetails.agency,
                    'destination': travelDetails.destination,
                    'departurePlace': travelDetails.departurePlace,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Réservation effectuée avec succès!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  String errorMessage = 'Erreur lors de la réservation. Veuillez réessayer.';

                  // Vérifiez si l'exception est un FirestoreException pour afficher plus de détails
                  if (e is FirebaseException) {
                    errorMessage = 'Erreur Firebase: ${e.message}';
                  } else if (e is FormatException) {
                    errorMessage = 'Erreur de format: ${e.message}';
                  } else {
                    errorMessage = 'Erreur inconnue: ${e.toString()}';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirmer la réservation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
