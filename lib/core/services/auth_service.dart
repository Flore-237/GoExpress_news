import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserProfile?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (!doc.exists) return null;
    
    return UserProfile.fromFirestore(doc);
  }

  Future<UserProfile> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userProfile = UserProfile(
        id: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userProfile.toMap());

      return userProfile;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userProfile = await getCurrentUserProfile();
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      return userProfile;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    if (currentUser == null) throw Exception('No authenticated user');
    
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update(profile.toMap());
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('Aucun utilisateur trouvé avec cet email');
        case 'wrong-password':
          return Exception('Mot de passe incorrect');
        case 'email-already-in-use':
          return Exception('Cet email est déjà utilisé');
        case 'weak-password':
          return Exception('Le mot de passe est trop faible');
        case 'invalid-email':
          return Exception('Email invalide');
        default:
          return Exception('Une erreur est survenue: ${e.message}');
      }
    }
    return Exception('Une erreur inattendue est survenue');
  }
}
