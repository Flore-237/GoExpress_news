import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/providers/agency_provider.dart';
import '../../../shared/providers/travel_provider.dart';
import '../widgets/ticket_view.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencies = ref.watch(agenciesProvider);
    final travels = ref.watch(travelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
      ),
      body: SingleChildScrollView(
        child: agencies.when(
          data: (agencyList) {
            final agency = agencyList.firstWhere(
              (a) => a.id == booking.agencyId,
              orElse: () => throw Exception('Agency not found'),
            );

            return travels.when(
              data: (travelList) {
                final travel = travelList.firstWhere(
                  (t) => t.id == booking.travelId,
                  orElse: () => throw Exception('Travel not found'),
                );

                if (booking.status == BookingStatus.confirmed) {
                  return TicketView(
                    booking: booking,
                    travel: travel,
                    agency: agency,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Statut: ${_getStatusText(booking.status)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(booking.status),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                agency.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${travel.departure} → ${travel.destination}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Le ${travel.departureTime.day}/${travel.departureTime.month}/${travel.departureTime.year} à ${travel.departureTime.hour}:${travel.departureTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const Divider(height: 32),
                              _buildInfoRow(
                                'Classe',
                                booking.travelClass.toString().split('.').last.toUpperCase(),
                              ),
                              _buildInfoRow(
                                'Passager',
                                booking.passengerInfo['fullName'],
                              ),
                              _buildInfoRow(
                                'Téléphone',
                                booking.passengerInfo['phoneNumber'],
                              ),
                              _buildInfoRow(
                                'Montant',
                                '${booking.amount.toStringAsFixed(0)} FCFA',
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (booking.status == BookingStatus.pending) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'En attente de paiement',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Veuillez effectuer le paiement pour confirmer votre réservation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text('Erreur: $error'),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text('Erreur: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmé';
      case BookingStatus.cancelled:
        return 'Annulé';
      case BookingStatus.completed:
        return 'Terminé';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }
}
