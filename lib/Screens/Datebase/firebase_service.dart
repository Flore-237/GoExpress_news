
// Firebase Service file

import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;


  FirebaseService();


  Future<bool> addUser() async {

    Map<String, dynamic> userData = {

      'name': 'leo',

    };

    try {

      await _db.collection('count').add(userData);

      return true;

    } catch (e) {

      return false;

    }

  }

}




