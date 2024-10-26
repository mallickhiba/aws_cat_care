import 'package:cloud_firestore/cloud_firestore.dart';

class AwsVolunteer {
  // Reference to the corresponding account document (optional)
  final String? accountRef;

  // Volunteer information
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  // Volunteer preferences and skills (optional)
  final List<String>? preferredActivities; // List of activities (e.g., feeding, adoption support)
  final List<String>? skills; // List of skills (e.g., animal handling, fundraising)

  // Optional fields
  final String? profilePictureUrl;
  final String? bio;

  AwsVolunteer({
    this.accountRef,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.preferredActivities,
    this.skills,
    this.profilePictureUrl,
    this.bio,
  });

  // Factory constructor for creating a AwsVolunteer from a Firestore document
  factory AwsVolunteer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AwsVolunteer.fromJson(data);
  }

  // Factory constructor for creating a AwsVolunteer from a JSON map
  factory AwsVolunteer.fromJson(Map<String, dynamic> json) {
    return AwsVolunteer(
      accountRef: json['accountRef'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      preferredActivities: (json['preferredActivities'] as List<dynamic>?)
          ?.map((activity) => activity as String)
          .toList(),
      skills: (json['skills'] as List<dynamic>?)
          ?.map((skill) => skill as String)
          .toList(),
      profilePictureUrl: json['profilePictureUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // Method to convert the AwsVolunteer object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'accountRef': accountRef,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'preferredActivities': preferredActivities,
      'skills': skills,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
    };
  }
}