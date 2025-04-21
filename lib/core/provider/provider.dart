import '../../data/models/reservationModel.dart';
import '../../data/models/routeModel.dart';
import '../../data/models/userModel.dart';
import '../../data/service/authenService.dart';
import '../../data/service/reservationService.dart';
import '../../data/service/routeService.dart';


// Providers de service
final authServiceProvider = Provider((ref) => AuthService());
final routeServiceProvider = Provider((ref) => RouteService());
final bookingServiceProvider = Provider((ref) => BookingService());

// Provider d'authentification
final authStateProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  Future<void> signIn(String email, String password) async {
    final user = await _authService.signIn(email, password);
    state = user;
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    final user = await _authService.signUp(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      role: role,
    );
    state = user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }
}

// Provider de recherche de routes
final routeSearchProvider = StateNotifierProvider<RouteSearchNotifier, List<RouteModel>>((ref) {
  return RouteSearchNotifier(ref.read(routeServiceProvider));
});

class RouteSearchNotifier extends StateNotifier<List<RouteModel>> {
  final RouteService _routeService;

  RouteSearchNotifier(this._routeService) : super([]);

  Future<void> searchRoutes({
    required String departure,
    required String destination,
    DateTime? date
  }) async {
    state = await _routeService.searchRoutes(
        departure: departure,
        destination: destination,
        date: date
    );
  }
}

// Provider de réservations
final bookingProvider = StateNotifierProvider<BookingNotifier, List<BookingModel>>((ref) {
  return BookingNotifier(
      ref.read(bookingServiceProvider),
      ref.read(authServiceProvider)
  );
});

class BookingNotifier extends StateNotifier<List<BookingModel>> {
  final BookingService _bookingService;
  final AuthService _authService;

  BookingNotifier(this._bookingService, this._authService) : super([]);

  Future<BookingModel?> createBooking(BookingModel booking) async {
    final createdBooking = await _bookingService.createBooking(booking);
    if (createdBooking != null) {
      state = [...state, createdBooking];
    }
    return createdBooking;
  }

  Future<void> loadUserBookings() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      state = await _bookingService.getUserBookings(currentUser.id);
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    final success = await _bookingService.cancelBooking(bookingId);
    if (success) {
      state = state.where((booking) => booking.id != bookingId).toList();
    }
    return success;
  }
}