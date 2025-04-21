import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/database_service.dart';
import '../models/travel.dart';

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedDepartureProvider = StateProvider<String?>((ref) => null);
final selectedDestinationProvider = StateProvider<String?>((ref) => null);

final travelsProvider = StreamProvider.autoDispose<List<Travel>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final selectedAgency = ref.watch(selectedAgencyProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final selectedDeparture = ref.watch(selectedDepartureProvider);
  final selectedDestination = ref.watch(selectedDestinationProvider);

  return databaseService.streamTravels(
    agencyId: selectedAgency?.id,
    date: selectedDate,
    departure: selectedDeparture,
    destination: selectedDestination,
  );
});

final filteredTravelsProvider = Provider<List<Travel>>((ref) {
  final travelsAsync = ref.watch(travelsProvider);
  
  return travelsAsync.when(
    data: (travels) {
      final departure = ref.watch(selectedDepartureProvider);
      final destination = ref.watch(selectedDestinationProvider);
      final date = ref.watch(selectedDateProvider);

      return travels.where((travel) {
        if (departure != null && travel.departure != departure) return false;
        if (destination != null && travel.destination != destination) return false;
        if (date != null) {
          final travelDate = DateTime(
            travel.departureTime.year,
            travel.departureTime.month,
            travel.departureTime.day,
          );
          final selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
          );
          if (travelDate != selectedDate) return false;
        }
        return true;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
