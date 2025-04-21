import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routeModel.dart';


class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<RouteModel>> searchRoutes({
    required String departure,
    required String destination,
    DateTime? date
  }) async {
    try {
      Query query = _firestore.collection('routes')
          .where('departure', isEqualTo: departure)
          .where('destination', isEqualTo: destination);

      if (date != null) {
        query = query.where('departureDate', isGreaterThanOrEqualTo: date);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => RouteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche de routes : $e');
      return [];
    }
  }

  Future<RouteModel?> getRouteById(String routeId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('routes').doc(routeId).get();
      return doc.exists ? RouteModel.fromFirestore(doc) : null;
    } catch (e) {
      print('Erreur lors de la récupération de la route : $e');
      return null;
    }
  }

  Future<List<RouteModel>> getRoutesByAgency(String agencyId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('routes')
          .where('agencyId', isEqualTo: agencyId)
          .get();

      return querySnapshot.docs
          .map((doc) => RouteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des routes par agence : $e');
      return [];
    }
  }

  Future<bool> createRoute(RouteModel route) async {
    try {
      await _firestore.collection('routes').add(route.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la création de la route : $e');
      return false;
    }
  }

  Future<bool> updateRoute(RouteModel route) async {
    try {
      await _firestore.collection('routes').doc(route.id).update(route.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la route : $e');
      return false;
    }
  }
}