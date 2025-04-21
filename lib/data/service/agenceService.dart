import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/agenceModel.dart';
import '../models/ticketModel.dart';

class AgencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<List<AgencyModel>> fetchAllAgencies() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('agencies').get();
      return snapshot.docs
          .map((doc) => AgencyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching agencies: $e');
      rethrow;
    }
  }

  Future<Map<String, List<String>>> fetchUniqueLocations() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('trips').get();

      Set<String> departures = Set();
      Set<String> destinations = Set();

      for (var doc in snapshot.docs) {
        departures.add(doc['departure']);
        destinations.add(doc['destination']);
      }

      return {
        'departures': departures.toList(),
        'destinations': destinations.toList(),
      };
    } catch (e) {
      print('Error fetching locations: $e');
      rethrow;
    }
  }


  Future<List<TripModel>> searchTrips({
    required String departure,
    required String destination,
    DateTime? date
  }) async {
    try {
      Query query = _firestore.collection('trips')
          .where('departure', isEqualTo: departure)
          .where('destination', isEqualTo: destination)
          .where('availableSeats', isGreaterThan: 0);


      if (date != null) {
        query = query.where('departureTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(date),
            isLessThan: Timestamp.fromDate(date.add(const Duration(days: 1)))
        );
      }

      // Sort by departure time
      query = query.orderBy('departureTime');

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching trips: $e');
      rethrow;
    }
  }

  // Fetch trips for a specific agency
  Future<List<TripModel>> fetchAgencyTrips(String agencyId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('trips')
          .where('agencyId', isEqualTo: agencyId)
          .get();

      return snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching agency trips: $e');
      rethrow;
    }
  }

  // Get agency details by ID
  Future<AgencyModel?> getAgencyById(String agencyId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('agencies').doc(agencyId).get();

      if (doc.exists) {
        return AgencyModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching agency details: $e');
      rethrow;
    }
  }
}