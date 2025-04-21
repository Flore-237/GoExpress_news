import 'package:flutter/material.dart';

class ReservationSummary extends StatelessWidget {
  final dynamic trip;
  final String? selectedSeat;

  const ReservationSummary({
    Key? key,
    required this.trip,
    this.selectedSeat
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de la Réservation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            Text('Trajet: ${trip.departureLocation} - ${trip.arrivalLocation}'),
            Text('Date: ${trip.departureDateTime}'),
            Text('Siège: ${selectedSeat ?? "Non sélectionné"}'),
            Text('Prix: ${trip.price} FCFA'),
          ],
        ),
      ),
    );
  }
}