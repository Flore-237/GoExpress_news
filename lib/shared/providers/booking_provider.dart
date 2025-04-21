import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/database_service.dart';
import '../../core/services/payment_service.dart';
import '../models/booking.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());

final userBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final userProfile = ref.watch(userProfileProvider);
  
  return userProfile.when(
    data: (profile) {
      if (profile == null) return Stream.value([]);
      return databaseService.streamUserBookings(profile.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final selectedTravelClassProvider = StateProvider<TravelClass>((ref) => TravelClass.classic);

final bookingProcessProvider = StateNotifierProvider<BookingProcessNotifier, AsyncValue<void>>((ref) {
  return BookingProcessNotifier(ref);
});

class BookingProcessNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  
  BookingProcessNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> createBooking({
    required String travelId,
    required TravelClass travelClass,
    required Map<String, dynamic> passengerInfo,
    required PaymentMethod paymentMethod,
    required String phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final databaseService = _ref.read(databaseServiceProvider);
      final paymentService = _ref.read(paymentServiceProvider);
      final userProfile = await _ref.read(userProfileProvider.future);
      
      if (userProfile == null) {
        throw Exception('User not authenticated');
      }

      // Create booking
      final booking = Booking(
        id: '',
        userId: userProfile.id,
        travelId: travelId,
        agencyId: _ref.read(selectedAgencyProvider)?.id ?? '',
        travelClass: travelClass,
        bookingDate: DateTime.now(),
        status: BookingStatus.pending,
        paymentMethod: paymentMethod,
        amount: _ref.read(selectedTravelProvider)?.getPrice(travelClass) ?? 0,
        passengerInfo: passengerInfo,
      );

      final createdBooking = await databaseService.createBooking(booking);

      // Initiate payment
      final paymentResult = await paymentService.initiatePayment(
        bookingId: createdBooking.id,
        method: paymentMethod,
        amount: booking.amount,
        phoneNumber: phoneNumber,
      );

      // Update booking with payment reference
      await databaseService.updatePaymentInfo(
        createdBooking.id,
        paymentReference: paymentResult['transactionId'],
        ticketNumber: paymentResult['ticketNumber'],
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
