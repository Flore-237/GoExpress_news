import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reservationModel.dart';
import '../../data/repositories/routeRepositories.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository();
});

final routeSearchProvider = StateNotifierProvider<RouteSearchNotifier, List<BookingModel>>((ref) {
  final repository = ref.watch(routeRepositoryProvider);
  return RouteSearchNotifier(repository);
});

class RouteSearchNotifier extends StateNotifier<List<BookingModel>> {
  final RouteRepository _repository;

  RouteSearchNotifier(this._repository) : super([]);

  Future<void> searchRoutes({
    required String departure,
    required String destination,
    DateTime? departureDate,
  }) async {
    final routes = await _repository.searchRoutes(
        departure: departure,
        destination: destination,
        departureDate: departureDate
    );
    state = routes.cast<BookingModel>();
  }
}