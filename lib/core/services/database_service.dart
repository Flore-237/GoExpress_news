import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/agency.dart';
import '../../shared/models/travel.dart';
import '../../shared/models/booking.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Agency Methods
  Stream<List<Agency>> streamAgencies() {
    return _firestore
        .collection('agencies')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Agency.fromFirestore(doc))
            .toList());
  }

  Future<Agency> getAgency(String agencyId) async {
    final doc = await _firestore.collection('agencies').doc(agencyId).get();
    if (!doc.exists) throw Exception('Agency not found');
    return Agency.fromFirestore(doc);
  }

  // Travel Methods
  Stream<List<Travel>> streamTravels({
    String? agencyId,
    String? departure,
    String? destination,
    DateTime? date,
  }) {
    Query query = _firestore.collection('travels');
    
    if (agencyId != null) {
      query = query.where('agencyId', isEqualTo: agencyId);
    }
    
    if (departure != null) {
      query = query.where('departure', isEqualTo: departure);
    }
    
    if (destination != null) {
      query = query.where('destination', isEqualTo: destination);
    }
    
    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      query = query
          .where('departureTime', isGreaterThanOrEqualTo: startOfDay)
          .where('departureTime', isLessThan: endOfDay);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Travel.fromFirestore(doc)).toList());
  }

  Future<List<String>> getAvailableDestinations() async {
    final snapshot = await _firestore.collection('travels').get();
    final destinations = snapshot.docs
        .map((doc) => doc.data()['destination'] as String)
        .toSet()
        .toList();
    return destinations;
  }

  Future<List<String>> getAvailableDepartures() async {
    final snapshot = await _firestore.collection('travels').get();
    final departures = snapshot.docs
        .map((doc) => doc.data()['departure'] as String)
        .toSet()
        .toList();
    return departures;
  }

  // Booking Methods
  Future<Booking> createBooking(Booking booking) async {
    final docRef = await _firestore.collection('bookings').add(booking.toMap());
    
    // Update available seats
    final travelRef = _firestore.collection('travels').doc(booking.travelId);
    await _firestore.runTransaction((transaction) async {
      final travelDoc = await transaction.get(travelRef);
      final travel = Travel.fromFirestore(travelDoc);
      
      if (booking.travelClass == TravelClass.vip) {
        if (travel.availableSeatsVIP <= 0) {
          throw Exception('No VIP seats available');
        }
        transaction.update(travelRef, {
          'availableSeatsVIP': travel.availableSeatsVIP - 1
        });
      } else {
        if (travel.availableSeatsClassic <= 0) {
          throw Exception('No Classic seats available');
        }
        transaction.update(travelRef, {
          'availableSeatsClassic': travel.availableSeatsClassic - 1
        });
      }
    });

    return booking.copyWith(id: docRef.id);
  }

  Stream<List<Booking>> streamUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status.toString()});
  }

  Future<void> updatePaymentInfo(
    String bookingId, {
    required String paymentReference,
    required String ticketNumber,
  }) {
    return _firestore.collection('bookings').doc(bookingId).update({
      'paymentReference': paymentReference,
      'ticketNumber': ticketNumber,
      'status': BookingStatus.confirmed.toString(),
    });
  }
}
