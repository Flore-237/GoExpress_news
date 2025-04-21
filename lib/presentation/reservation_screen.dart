import 'package:flutter/material.dart';

import '../core/utils/widget/seat_selector.dart';
import '../core/utils/widget/toute_reservation.dart';

class ReservationScreen extends StatefulWidget {
  final dynamic trip;

  const ReservationScreen({Key? key, required this.trip}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String? _selectedSeat;

  void _onSeatSelected(String seat) {
    setState(() {
      _selectedSeat = seat;
    });
  }

  void _confirmReservation() {
    if (_selectedSeat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un siège')),
      );
      return;
    }
    // Logique de confirmation de réservation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Réservation')),
      body: Column(
        children: [
          SeatSelector(
            availableSeats: widget.trip.availableSeats,
            onSeatSelected: _onSeatSelected,
          ),
          ReservationSummary(
            trip: widget.trip,
            selectedSeat: _selectedSeat,
          ),
          ElevatedButton(
            onPressed: _confirmReservation,
            child: Text('Confirmer la réservation'),
          )
        ],
      ),
    );
  }
}