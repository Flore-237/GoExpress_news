import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(userBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
      ),
      body: bookings.when(
        data: (bookingList) {
          if (bookingList.isEmpty) {
            return const Center(
              child: Text('Aucune réservation'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookingList.length,
            itemBuilder: (context, index) {
              final booking = bookingList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BookingCard(booking: booking),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}
