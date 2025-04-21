import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/agency_provider.dart';
import '../../../shared/providers/travel_provider.dart';
import '../widgets/agency_card.dart';
import '../widgets/travel_search_form.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencies = ref.watch(agenciesProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoExpress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(agenciesProvider);
          ref.refresh(travelsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userProfile.when(
                data: (profile) => profile != null
                    ? Text(
                        'Bonjour, ${profile.fullName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox(),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 24),
              const TravelSearchForm(),
              const SizedBox(height: 24),
              const Text(
                'Agences de voyage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              agencies.when(
                data: (agencyList) {
                  if (agencyList.isEmpty) {
                    return const Center(
                      child: Text('Aucune agence disponible'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: agencyList.length,
                    itemBuilder: (context, index) {
                      final agency = agencyList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AgencyCard(agency: agency),
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
            ],
          ),
        ),
      ),
    );
  }
}
