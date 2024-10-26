import 'package:cloud_firestore/cloud_firestore.dart';

class AwsPanelMember {
  // Reference to the corresponding account document (optional)
  final String? accountRef;

  // Panel member information
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  // Panel member role and responsibilities
  final String role; // E.g., President, Vice President, Treasurer, etc.
  final List<String> responsibilities; // List of responsibilities

  // Optional fields
  final String? profilePictureUrl;
  final String? bio;

  AwsPanelMember({
    this.accountRef,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.responsibilities,
    this.profilePictureUrl,
    this.bio,
  });

  // Factory constructor for creating a AwsPanelMember from a Firestore document
  factory AwsPanelMember.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AwsPanelMember.fromJson(data);
  }

  // Factory constructor for creating a AwsPanelMember from a JSON map
  factory AwsPanelMember.fromJson(Map<String, dynamic> json) {
    return AwsPanelMember(
      accountRef: json['accountRef'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      responsibilities: (json['responsibilities'] as List<dynamic>)
          .map((responsibility) => responsibility as String)
          .toList(),
      profilePictureUrl: json['profilePictureUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // Method to convert the AwsPanelMember object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'accountRef': accountRef,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'responsibilities': responsibilities,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
    };
  }
}