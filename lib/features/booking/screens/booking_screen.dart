import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/agency.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/providers/booking_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Travel travel;
  final Agency? agency;

  const BookingScreen({
    super.key,
    required this.travel,
    this.agency,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.mobileMoney;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedClass = ref.watch(selectedTravelClassProvider);
    final bookingProcess = ref.watch(bookingProcessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.agency != null)
                        Text(
                          widget.agency!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.travel.departure} → ${widget.travel.destination}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Départ le ${widget.travel.departureTime.day}/${widget.travel.departureTime.month}/${widget.travel.departureTime.year} à ${widget.travel.departureTime.hour}:${widget.travel.departureTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Type de billet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.travel.availableSeatsVIP > 0)
                    Expanded(
                      child: _buildClassSelector(
                        context,
                        TravelClass.vip,
                        'VIP',
                        widget.travel.priceVIP,
                        selectedClass == TravelClass.vip,
                      ),
                    ),
                  if (widget.travel.availableSeatsVIP > 0 &&
                      widget.travel.availableSeatsClassic > 0)
                    const SizedBox(width: 16),
                  if (widget.travel.availableSeatsClassic > 0)
                    Expanded(
                      child: _buildClassSelector(
                        context,
                        TravelClass.classic,
                        'Classic',
                        widget.travel.priceClassic,
                        selectedClass == TravelClass.classic,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Informations passager',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fullNameController,
                label: 'Nom complet',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du passager';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Mode de paiement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: bookingProcess.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        await ref.read(bookingProcessProvider.notifier).createBooking(
                              travelId: widget.travel.id,
                              travelClass: selectedClass,
                              passengerInfo: {
                                'fullName': _fullNameController.text.trim(),
                                'phoneNumber': _phoneController.text.trim(),
                              },
                              paymentMethod: _selectedPaymentMethod,
                              phoneNumber: _phoneController.text.trim(),
                            );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Réservation effectuée avec succès'),
                            ),
                          );
                        }
                      },
                isLoading: bookingProcess.isLoading,
                text:
                    'Payer ${widget.travel.getPrice(selectedClass).toStringAsFixed(0)} FCFA',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSelector(
    BuildContext context,
    TravelClass travelClass,
    String label,
    double price,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedTravelClassProvider.notifier).state = travelClass;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${price.toStringAsFixed(0)} FCFA',
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.mobileMoney,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
          title: const Text('Mobile Money'),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.orangeMoney,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
          title: const Text('Orange Money'),
        ),
      ],
    );
  }
}
