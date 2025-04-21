import 'package:cloud_firestore/cloud_firestore.dart';

class Agency {
  final String id;
  final String name;
  final String logo;
  final String description;
  final List<String> routes;
  final List<String> services;
  final Map<String, dynamic> contactInfo;

  Agency({
    required this.id,
    required this.name,
    required this.logo,
    required this.description,
    required this.routes,
    required this.services,
    required this.contactInfo,
  });

  factory Agency.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Agency(
      id: doc.id,
      name: data['name'] ?? '',
      logo: data['logo'] ?? '',
      description: data['description'] ?? '',
      routes: List<String>.from(data['routes'] ?? []),
      services: List<String>.from(data['services'] ?? []),
      contactInfo: Map<String, dynamic>.from(data['contactInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logo': logo,
      'description': description,
      'routes': routes,
      'services': services,
      'contactInfo': contactInfo,
    };
  }
}
