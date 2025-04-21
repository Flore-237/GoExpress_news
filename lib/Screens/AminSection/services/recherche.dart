import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, List<String>>> fetchLocationsIsolate() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('agences')
      .get();

  Set<String> departures = {};
  Set<String> destinations = {};

  for (var doc in snapshot.docs) {
    if (doc.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('departures') && data['departures'] != null) {
        if (data['departures'] is List) {
          List<dynamic> depList = data['departures'];
          departures.addAll(depList
              .where((dep) => dep != null && dep.toString().trim().isNotEmpty)
              .map((dep) => dep.toString().trim()));
        } else if (data['departures'] is String) {
          String deps = data['departures'].toString().trim();
          if (deps.isNotEmpty) departures.add(deps);
        }
      }

      if (data.containsKey('destinations') && data['destinations'] != null) {
        if (data['destinations'] is List) {
          List<dynamic> destList = data['destinations'];
          destinations.addAll(destList
              .where((dest) => dest != null && dest.toString().trim().isNotEmpty)
              .map((dest) => dest.toString().trim()));
        } else if (data['destinations'] is String) {
          String dests = data['destinations'].toString().trim();
          if (dests.isNotEmpty) destinations.add(dests);
        }
      }
    }
  }

  return {
    'departures': departures.toList()..sort(),
    'destinations': destinations.toList()..sort()
  };
}

Future<List<String>> fetchAgenciesIsolate() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('agences')
      .get();
  return snapshot.docs.map((doc) => doc.id).toList()..sort();
}