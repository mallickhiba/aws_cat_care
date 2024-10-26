import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Cat {
  // Reference to the corresponding account document (optional)
  final String? accountRef;

  // Cat information
  final String name;
  final String breed;
  final int age;
  final List<String> photos; // List of image URLs
  final bool isAvailableForAdoption;
  final bool isFixed;

  // Location information
  final GeoPoint? lastSeenLocation;
  final GeoPoint? usualLocation;

  // Optional information
  final String? description;

  Cat({
    this.accountRef,
    required this.name,
    required this.breed,
    required this.age,
    required this.photos,
    required this.isAvailableForAdoption,
    required this.isFixed,
    this.lastSeenLocation,
    this.usualLocation,
    this.description,
  });

  // Factory constructor for creating a Cat from a Firestore document
  factory Cat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Cat.fromJson(data);
  }

  // Factory constructor for creating a Cat from a JSON map
  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      accountRef: json['accountRef'] as String?,
      name: json['name'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      photos: (json['photos'] as List<dynamic>).map((photo) => photo as String).toList(),
      isAvailableForAdoption: json['isAvailableForAdoption'] as bool,
      isFixed: json['isFixed'] as bool,
      lastSeenLocation: (json['lastSeenLocation'] as GeoPoint?)?.toLatLng(),
      usualLocation: (json['usualLocation'] as GeoPoint?)?.toLatLng(),
      description: json['description'] as String?,
    );
  }

  // Method to convert the Cat object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'accountRef': accountRef,
      'name': name,
      'breed': breed,
      'age': age,
      'photos': photos,
      'isAvailableForAdoption': isAvailableForAdoption,
      'isFixed': isFixed,
      'lastSeenLocation': lastSeenLocation?.toGeoPoint(),
      'usualLocation': usualLocation?.toGeoPoint(),
      'description': description,
    };
  }
}