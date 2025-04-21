import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/agency.dart';
import '../../../shared/providers/travel_provider.dart';
import '../widgets/travel_card.dart';

class TravelListScreen extends ConsumerWidget {
  final Agency agency;

  const TravelListScreen({
    super.key,
    required this.agency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travels = ref.watch(travelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(agency.name),
      ),
      body: travels.when(
        data: (travelList) {
          if (travelList.isEmpty) {
            return const Center(
              child: Text('Aucun voyage disponible'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: travelList.length,
            itemBuilder: (context, index) {
              final travel = travelList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TravelCard(
                  travel: travel,
                  agency: agency,
                ),
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
