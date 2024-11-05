import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerModel {
  // Reference to the corresponding account document (optional)
  final String? id;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? availabilty;
  final String? profilePictureUrl;
  final String? bio;

  VolunteerModel({
    this.id,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.availabilty,
    this.profilePictureUrl,
    this.bio,
  });

  factory VolunteerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VolunteerModel.fromJson(data);
  }

  factory VolunteerModel.fromJson(Map<String, dynamic> json) {
    return VolunteerModel(
      id: json['id'] as String?,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      availabilty: json['availabilty'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // Method to convert the VolunteerModel object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'availability': availabilty,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
    };
  }
}
