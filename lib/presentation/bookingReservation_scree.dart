import 'package:busexpress/data/models/ticketModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_scaffold.dart';
import 'busRoute.dart';

class BookingScreen extends StatefulWidget {
  final BusRoute route;

  const BookingScreen({Key? key, required this.route}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isVip = false;
  PaymentMethod _paymentMethod = PaymentMethod.mobileMoney;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Réservation',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.route.departure} → ${widget.route.destination}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Options de réservation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SwitchListTile(
                      title: Text('Réservation VIP'),
                      value: _isVip,
                      onChanged: (bool value) {
                        setState(() {
                          _isVip = value;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Méthode de paiement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RadioListTile<PaymentMethod>(
                      title: Text('Mobile Money'),
                      value: PaymentMethod.mobileMoney,
                      groupValue: _paymentMethod,
                      onChanged: (PaymentMethod? value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      title: Text('Orange Money'),
                      value: PaymentMethod.orangeMoney,
                      groupValue: _paymentMethod,
                      onChanged: (PaymentMethod? value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _confirmBooking,
              child: Text('Confirmer la réservation'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking() {
    // TODO: Implémenter la logique de réservation
    // 1. Vérifier la disponibilité des sièges
    // 2. Créer une réservation
    // 3. Traiter le paiement
    // 4. Générer le ticket
  }
}

enum PaymentMethod {
  mobileMoney,
  orangeMoney,
}