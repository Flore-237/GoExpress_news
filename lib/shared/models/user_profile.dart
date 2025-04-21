import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? photoUrl;
  final List<String> favoriteAgencies;
  final Map<String, dynamic> preferences;
  final bool isAdmin;
  final String? associatedAgencyId;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.photoUrl,
    this.favoriteAgencies = const [],
    this.preferences = const {},
    this.isAdmin = false,
    this.associatedAgencyId,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      photoUrl: data['photoUrl'],
      favoriteAgencies: List<String>.from(data['favoriteAgencies'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      isAdmin: data['isAdmin'] ?? false,
      associatedAgencyId: data['associatedAgencyId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'favoriteAgencies': favoriteAgencies,
      'preferences': preferences,
      'isAdmin': isAdmin,
      'associatedAgencyId': associatedAgencyId,
    };
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
    List<String>? favoriteAgencies,
    Map<String, dynamic>? preferences,
    bool? isAdmin,
    String? associatedAgencyId,
  }) {
    return UserProfile(
      id: this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteAgencies: favoriteAgencies ?? this.favoriteAgencies,
      preferences: preferences ?? this.preferences,
      isAdmin: isAdmin ?? this.isAdmin,
      associatedAgencyId: associatedAgencyId ?? this.associatedAgencyId,
    );
  }
}
