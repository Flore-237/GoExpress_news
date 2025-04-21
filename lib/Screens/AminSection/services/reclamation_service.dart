import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reclamation.dart';

class ReclamationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch reclamations from Firestore
  Stream<List<Reclamation>> getReclamations() {
    return _firestore.collection('reclamations').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Reclamation.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Add a new reclamation to Firestore
  Future<void> ajouterReclamation(Reclamation reclamation) async {
    await _firestore.collection('reclamations').add(reclamation.toMap());
  }

  // Update an existing reclamation
  Future<void> mettreAJourReclamation(Reclamation reclamation) async {
    await _firestore.collection('reclamations').doc(reclamation.id).update(reclamation.toMap());
  }

  // Delete a reclamation from Firestore
  Future<void> supprimerReclamation(String reclamationId) async {
    await _firestore.collection('reclamations').doc(reclamationId).delete();
  }

  // Add a comment to an existing reclamation
  Future<void> ajouterCommentaire(String reclamationId, String comment) async {
    await _firestore.collection('reclamations').doc(reclamationId).update({
      'commentaires': FieldValue.arrayUnion([comment]),
    });
  }
}