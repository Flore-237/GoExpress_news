import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/travel_provider.dart';
import '../widgets/travel_card.dart';

class TravelSearchResultsScreen extends ConsumerWidget {
  const TravelSearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTravels = ref.watch(filteredTravelsProvider);
    final departure = ref.watch(selectedDepartureProvider);
    final destination = ref.watch(selectedDestinationProvider);
    final date = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats de recherche'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$departure → $destination',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${date?.day}/${date?.month}/${date?.year}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTravels.isEmpty
                ? const Center(
                    child: Text('Aucun voyage disponible'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTravels.length,
                    itemBuilder: (context, index) {
                      final travel = filteredTravels[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TravelCard(
                          travel: travel,
                          showAgencyName: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
