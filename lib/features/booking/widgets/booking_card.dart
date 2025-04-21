import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/providers/agency_provider.dart';
import '../../../shared/providers/travel_provider.dart';

class BookingCard extends ConsumerWidget {
  final Booking booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencies = ref.watch(agenciesProvider);
    final travels = ref.watch(travelsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réservation #${booking.ticketNumber ?? booking.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(context, booking.status),
              ],
            ),
            const SizedBox(height: 16),
            agencies.when(
              data: (agencyList) {
                final agency = agencyList.firstWhere(
                  (a) => a.id == booking.agencyId,
                  orElse: () => throw Exception('Agency not found'),
                );
                return Text(
                  agency.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 8),
            travels.when(
              data: (travelList) {
                final travel = travelList.firstWhere(
                  (t) => t.id == booking.travelId,
                  orElse: () => throw Exception('Travel not found'),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${travel.departure} → ${travel.destination}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Départ le ${travel.departureTime.day}/${travel.departureTime.month}/${travel.departureTime.year} à ${travel.departureTime.hour}:${travel.departureTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.passengerInfo['fullName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.passengerInfo['phoneNumber'],
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${booking.amount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.travelClass.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BookingStatus status) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        label = 'Confirmé';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Annulé';
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        label = 'Terminé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
