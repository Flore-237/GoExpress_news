import 'package:flutter/material.dart';

import 'ReservationScreen.dart';

// Constantes de couleurs
class AppColors {
  static const Color primary = Color(0xFF3D56F0);  // Couleur principale
  static const Color text = Colors.black87;        // Couleur du texte
  static const Color backgroundWhite = Colors.white; // Couleur de fond
  static const Color divider = Colors.grey;        // Couleur du séparateur
}

// Styles de texte
class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: AppColors.text,
  );

  static const TextStyle value = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
}

// Modèle de données
class TravelDetails {
  final String agency;
  final String destination;
  final String departurePlace;
  final int totalSeats;
  final int availableSeats;
  final int regularPrice;
  final int vipPrice;

  TravelDetails({
    required this.agency,
    required this.destination,
    required this.departurePlace,
    required this.totalSeats,
    required this.availableSeats,
    required this.regularPrice,
    required this.vipPrice, required String time,
  });
}

// Row affichant une information
class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value, style: AppTextStyles.value),
        ],
      ),
    );
  }
}

// Row affichant une option de prix
class PriceRow extends StatelessWidget {
  final String category;
  final int price;
  final bool isSelected;
  final VoidCallback onTap;

  const PriceRow({
    Key? key,
    required this.category,
    required this.price,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
  return GestureDetector(
  onTap: onTap,
  child: Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
  color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(
  color: AppColors.divider,
  ),
  ),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Text(category, style: AppTextStyles.label),
  Text('FCFA ${price.toString()}', style: AppTextStyles.price), // Modification ici
  ],
  ),
  ),
  );
  }
  }

// Écran affichant les détails du voyage
class TravelDetailsScreen extends StatefulWidget {
  final TravelDetails travelDetails;

  const TravelDetailsScreen({
    Key? key,
    required this.travelDetails,
  }) : super(key: key);

  @override
  _TravelDetailsScreenState createState() => _TravelDetailsScreenState();
}

class _TravelDetailsScreenState extends State<TravelDetailsScreen> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails du voyage',
          style: AppTextStyles.title,
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DetailRow(label: 'Agence', value: widget.travelDetails.agency),
            DetailRow(label: 'Destination', value: widget.travelDetails.destination),
            DetailRow(label: 'Lieu de départ', value: widget.travelDetails.departurePlace),
            DetailRow(label: 'Nombre de places', value: widget.travelDetails.totalSeats.toString()),
            DetailRow(label: 'Places disponibles', value: widget.travelDetails.availableSeats.toString()),
            const SizedBox(height: 16),
            const Text('Prix', style: AppTextStyles.label),
            const SizedBox(height: 8),
            PriceRow(
              category: 'Classique',
              price: widget.travelDetails.regularPrice,
              isSelected: selectedCategory == 'Classique',
              onTap: () => setState(() => selectedCategory = 'Classique'),
            ),
            const SizedBox(height: 8),
            PriceRow(
              category: 'VIP',
              price: widget.travelDetails.vipPrice,
              isSelected: selectedCategory == 'VIP',
              onTap: () => setState(() => selectedCategory = 'VIP'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedCategory != null
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationScreen(
                      travelDetails: widget.travelDetails,
                      selectedCategory: selectedCategory!,
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Réserver ma place',
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

