import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agenceModel.dart';

class AgencyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new agency
  Future<AgencyModel?> createAgency(AgencyModel agency) async {
    try {
      final docRef = await _firestore.collection('agencies').add(agency.toFirestore());
      return agency.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating agency: $e');
      return null;
    }
  }

  // Get all agencies
  Future<List<AgencyModel>> getAllAgencies() async {
    try {
      final snapshot = await _firestore.collection('agencies').get();
      return snapshot.docs
          .map((doc) => AgencyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching agencies: $e');
      return [];
    }
  }

  // Get a single agency by ID
  Future<AgencyModel?> getAgencyById(String id) async {
    try {
      final doc = await _firestore.collection('agencies').doc(id).get();
      if (doc.exists) {
        return AgencyModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching agency: $e');
      return null;
    }
  }

  // Update an existing agency
  Future<bool> updateAgency(AgencyModel agency) async {
    try {
      if (agency.id.isEmpty) return false;

      await _firestore
          .collection('agencies')
          .doc(agency.id)
          .update(agency.toFirestore());
      return true;
    } catch (e) {
      print('Error updating agency: $e');
      return false;
    }
  }

  // Delete an agency
  Future<bool> deleteAgency(String id) async {
    try {
      await _firestore.collection('agencies').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting agency: $e');
      return false;
    }
  }

  // Stream of all agencies for real-time updates
  Stream<List<AgencyModel>> agenciesStream() {
    return _firestore
        .collection('agencies')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AgencyModel.fromFirestore(doc))
        .toList());
  }

  // Get agencies with pagination
  Future<List<AgencyModel>> getAgenciesPaginated({int limit = 10, DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _firestore.collection('agencies').limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AgencyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching paginated agencies: $e');
      return [];
    }
  }
}