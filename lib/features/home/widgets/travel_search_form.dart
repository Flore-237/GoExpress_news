import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/travel_provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../travel/screens/travel_search_results_screen.dart';

class TravelSearchForm extends ConsumerWidget {
  const TravelSearchForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departures = ref.watch(departuresProvider);
    final destinations = ref.watch(destinationsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rechercher un voyage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            departures.when(
              data: (departureList) {
                return DropdownButtonFormField<String>(
                  value: ref.watch(selectedDepartureProvider),
                  decoration: const InputDecoration(
                    labelText: 'Départ',
                  ),
                  items: departureList
                      .map((departure) => DropdownMenuItem(
                            value: departure,
                            child: Text(departure),
                          ))
                      .toList(),
                  onChanged: (value) {
                    ref.read(selectedDepartureProvider.notifier).state = value;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Erreur de chargement'),
            ),
            const SizedBox(height: 16),
            destinations.when(
              data: (destinationList) {
                return DropdownButtonFormField<String>(
                  value: ref.watch(selectedDestinationProvider),
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                  ),
                  items: destinationList
                      .map((destination) => DropdownMenuItem(
                            value: destination,
                            child: Text(destination),
                          ))
                      .toList(),
                  onChanged: (value) {
                    ref.read(selectedDestinationProvider.notifier).state = value;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Erreur de chargement'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Date',
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) {
                  ref.read(selectedDateProvider.notifier).state = date;
                }
              },
              controller: TextEditingController(
                text: selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : '',
              ),
              suffix: const Icon(Icons.calendar_today),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final departure = ref.read(selectedDepartureProvider);
                final destination = ref.read(selectedDestinationProvider);
                final date = ref.read(selectedDateProvider);

                if (departure != null && destination != null && date != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TravelSearchResultsScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                    ),
                  );
                }
              },
              child: const Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }
}
