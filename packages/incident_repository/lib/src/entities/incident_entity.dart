import 'package:cat_repository/cat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';

class IncidentEntity {
  final String id;
  final Cat cat;
  final DateTime reportDate;
  final MyUserEntity reportedBy;
  final bool vetVisit;
  final String description;
  final bool? followUp;
  final MyUserEntity volunteer;

  IncidentEntity({
    required this.id,
    required this.cat,
    required this.reportDate,
    required this.reportedBy,
    required this.vetVisit,
    required this.description,
    this.followUp,
    required this.volunteer,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'cat': cat.toDocument(),
      'reportDate': reportDate.toIso8601String(),
      'reportedBy': reportedBy.toDocument(),
      'vetVisit': vetVisit,
      'description': description,
      'followUp': followUp,
      'volunteer': volunteer.toDocument(),
    };
  }

  static IncidentEntity fromJson(Map<String, dynamic> json) {
    return IncidentEntity(
      id: json['id'] as String,
      cat: Cat.fromDocument(json['cat'] as Map<String, dynamic>),
      reportDate: DateTime.parse(json['reportDate'] as String),
      reportedBy:
          MyUserEntity.fromDocument(json['reportedBy'] as Map<String, dynamic>),
      vetVisit: json['vetVisit'] as bool,
      description: json['description'] as String,
      followUp: json['followUp'] as bool,
      volunteer:
          MyUserEntity.fromDocument(json['volunteer'] as Map<String, dynamic>),
    );
  }

  static IncidentEntity fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromJson(data);
  }

  copyWith({required String id}) {}
}
