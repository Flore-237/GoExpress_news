import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/database_service.dart';
import '../models/agency.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

final agenciesProvider = StreamProvider<List<Agency>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.streamAgencies();
});

final selectedAgencyProvider = StateProvider<Agency?>((ref) => null);

final departuresProvider = FutureProvider<List<String>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getAvailableDepartures();
});

final destinationsProvider = FutureProvider<List<String>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getAvailableDestinations();
});
