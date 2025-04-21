import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:flutter/foundation.dart';

enum UserRole { customer, agent, admin }

@immutable
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime registrationDate;
  final String? agencyId; // Optional, for agents

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.role = UserRole.customer,
    this.profileImageUrl,
    required this.registrationDate,
    this.agencyId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${data['role'] ?? 'customer'}',
      ),
      profileImageUrl: data['profileImageUrl'],
      registrationDate: (data['registrationDate'] as Timestamp).toDate(),
      agencyId: data['agencyId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'profileImageUrl': profileImageUrl,
      'registrationDate': registrationDate,
      'agencyId': agencyId,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profileImageUrl,
    String? agencyId,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      registrationDate: registrationDate,
      agencyId: agencyId ?? this.agencyId,
    );
  }
}