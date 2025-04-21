import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/userModel.dart';


import '../models/userModel.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    try {
      // Création de l'utilisateur avec Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      UserModel userModel = UserModel(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        role: role,
        registrationDate: DateTime.now(),
      );

      // Sauvegarder les détails dans Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('Erreur d\'inscription : ${e.message}');
      return null;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      // Récupérer les détails utilisateur depuis Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion : ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer l'utilisateur actuellement connecté
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      return UserModel.fromFirestore(userDoc);
    }
    return null;
  }

  // Réinitialisation du mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Erreur de réinitialisation de mot de passe : $e');
      return false;
    }
  }
}