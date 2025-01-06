import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';

class IncidentEntity {
  final String id;
  final String catId;
  final DateTime reportDate;
  final MyUserEntity reportedBy;
  final bool vetVisit;
  final String description;
  final bool? followUp;
  final MyUserEntity volunteer;
  List<String> photos;

  IncidentEntity({
    required this.id,
    required this.catId,
    required this.reportDate,
    required this.reportedBy,
    required this.vetVisit,
    required this.description,
    this.followUp,
    required this.volunteer,
    this.photos = const [],
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'catId': catId,
      'reportDate': reportDate.toIso8601String(),
      'reportedBy': reportedBy.toDocument(),
      'vetVisit': vetVisit,
      'description': description,
      'followUp': followUp,
      'volunteer': volunteer.toDocument(),
      'photos': photos,
    };
  }

  static IncidentEntity fromDocument(Map<String, dynamic> json) {
    return IncidentEntity(
      id: json['id'] as String,
      catId: json['catId'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      reportedBy:
          MyUserEntity.fromDocument(json['reportedBy'] as Map<String, dynamic>),
      vetVisit: json['vetVisit'] as bool,
      description: json['description'] as String,
      followUp: json['followUp'] as bool,
      volunteer:
          MyUserEntity.fromDocument(json['volunteer'] as Map<String, dynamic>),
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : [],
    );
  }

  static IncidentEntity fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromDocument(data);
  }

  List<Object?> get props => [
        id,
        catId,
        reportDate,
        reportedBy,
        vetVisit,
        description,
        followUp,
        volunteer,
        photos,
      ];

  @override
  String toString() {
    return '''IncidentEntity: {
      id: $id,
      catId: $catId,
      reportDate: $reportDate,
      reportedBy: $reportedBy,
      vetVisit: $vetVisit,
      description: $description,
      followUp: $followUp,
      volunteer: $volunteer
            photos: $photos
    }''';
  }
}
