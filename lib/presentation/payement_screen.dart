import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/service/payement_service.dart';
import '../core/utils/widget/payment_form.dart';
import '../core/utils/widget/payment_method_card.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> reservationData;

  const PaymentScreen({Key? key, required this.reservationData}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'Mobile Money';
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final paymentService = Provider.of<PaymentService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Détails de la réservation
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Détails de la réservation',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Agence', widget.reservationData['agencyName']),
                          _buildDetailRow('Départ', widget.reservationData['departure']),
                          _buildDetailRow('Destination', widget.reservationData['destination']),
                          _buildDetailRow('Date', widget.reservationData['date']),
                          _buildDetailRow('Heure', widget.reservationData['time']),
                          _buildDetailRow('Type', widget.reservationData['type']),
                          _buildDetailRow('Siège', widget.reservationData['seatNumber']),
                          const Divider(thickness: 1),
                          _buildDetailRow(
                              'Montant total',
                              '${widget.reservationData['price']} FCFA',
                              isTotal: true
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Méthodes de paiement
                  Text(
                    'Méthode de paiement',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: PaymentMethodCard(
                          iconData: Icons.phone_android,
                          title: 'Mobile Money',
                          isSelected: selectedPaymentMethod == 'Mobile Money',
                          onTap: () => setState(() => selectedPaymentMethod = 'Mobile Money'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PaymentMethodCard(
                          iconData: Icons.phone_iphone,
                          title: 'Orange Money',
                          isSelected: selectedPaymentMethod == 'Orange Money',
                          onTap: () => setState(() => selectedPaymentMethod = 'Orange Money'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Formulaire de paiement
                  PaymentForm(
                    paymentMethod: selectedPaymentMethod,
                    amount: widget.reservationData['price'],
                    onSubmit: (phoneNumber) async {
                      setState(() => isProcessing = true);

                      try {
                        final success = await paymentService.processMobilePayment(
                          paymentMethod: selectedPaymentMethod,
                          phoneNumber: phoneNumber,
                          amount: widget.reservationData['price'],
                          reservationId: widget.reservationData['id'],
                        );

                        if (!mounted) return;

                        if (success) {
                          Navigator.pushNamed(
                            context,
                            '/ticket',
                            arguments: {
                              ...widget.reservationData,
                              'paymentMethod': selectedPaymentMethod,
                              'paymentStatus': 'Payé',
                              'paymentDate': DateTime.now().toString(),
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Paiement échoué, veuillez réessayer'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isProcessing = false);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[900] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}