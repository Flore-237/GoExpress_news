import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class AgencyModel {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String imageUrl;
  final String contactEmail;
  final String phoneNumber;
  final String address;
  final bool isActive;
  final List<String> supportedRoutes;
  final String contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgencyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.imageUrl,
    required this.contactEmail,
    required this.phoneNumber,
    required this.address,
    this.isActive = true,
    this.supportedRoutes = const [],
    required this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgencyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgencyModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      isActive: data['isActive'] ?? true,
      supportedRoutes: List<String>.from(data['supportedRoutes'] ?? []),
      contactPhone: data['contactPhone'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  get safeLogoUrl => null;

  get logo => null;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'imageUrl': imageUrl,
      'contactEmail': contactEmail,
      'phoneNumber': phoneNumber,
      'address': address,
      'isActive': isActive,
      'supportedRoutes': supportedRoutes,
      'contactPhone': contactPhone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AgencyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? imageUrl,
    String? contactEmail,
    String? phoneNumber,
    String? address,
    bool? isActive,
    List<String>? supportedRoutes,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      supportedRoutes: supportedRoutes ?? this.supportedRoutes,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}