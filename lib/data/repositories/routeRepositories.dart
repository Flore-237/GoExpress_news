import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/routeModel.dart'; // Ensure this imports your RouteModel

class RouteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<RouteModel?> createRoute(RouteModel route) async {
    try {
      final docRef = await _firestore.collection('routes').add(route.toFirestore());
      return route.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating route: $e');
      return null;
    }
  }

  Future<List<RouteModel>> searchRoutes({
    required String departure,
    required String destination,
    DateTime? departureDate,
  }) async {
    try {
      Query query = _firestore.collection('routes')
          .where('departure', isEqualTo: departure)
          .where('destination', isEqualTo: destination);

      if (departureDate != null) {
        query = query.where('departureDate',
            isGreaterThanOrEqualTo: departureDate,
            isLessThan: departureDate.add(Duration(days: 1))
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RouteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching routes: $e');
      return [];
    }
  }
}