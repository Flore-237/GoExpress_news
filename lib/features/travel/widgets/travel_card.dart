import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/agency.dart';
import '../../../shared/models/travel.dart';
import '../../booking/screens/booking_screen.dart';

class TravelCard extends ConsumerWidget {
  final Travel travel;
  final Agency? agency;
  final bool showAgencyName;

  const TravelCard({
    super.key,
    required this.travel,
    this.agency,
    this.showAgencyName = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVIPSeats = travel.availableSeatsVIP > 0;
    final hasClassicSeats = travel.availableSeatsClassic > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(
                travel: travel,
                agency: agency,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAgencyName && agency != null) ...[
                Text(
                  agency!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: Column(
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
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (hasVIPSeats)
                        Text(
                          '${travel.priceVIP.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      if (hasClassicSeats)
                        Text(
                          '${travel.priceClassic.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: hasVIPSeats ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            color: hasVIPSeats ? Colors.grey : Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (hasVIPSeats)
                    _buildSeatInfo(
                      context,
                      'VIP',
                      travel.availableSeatsVIP,
                      Colors.purple,
                    ),
                  if (hasVIPSeats && hasClassicSeats)
                    const SizedBox(width: 16),
                  if (hasClassicSeats)
                    _buildSeatInfo(
                      context,
                      'Classic',
                      travel.availableSeatsClassic,
                      Colors.blue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatInfo(
    BuildContext context,
    String type,
    int seats,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_seat,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$seats $type',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
