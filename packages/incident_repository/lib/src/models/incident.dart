import 'package:user_repository/user_repository.dart';
import 'package:cat_repository/cat_repository.dart';

import '../entities/entities.dart';

class Incident {
  String id; // Unique ID for the incident
  Cat cat;
  DateTime reportDate; // Timestamp for when the incident was reported
  MyUser reportedBy; // The user who reported the incident
  bool vetVisit; // Indicates if a vet visit was required
  String description; // Description of the incident
  bool followUp; // Reference to another incident for follow-up
  MyUser volunteer; // The user/volunteer handling the incident

  Incident({
    required this.id,
    required this.cat,
    required this.reportDate,
    required this.reportedBy,
    required this.vetVisit,
    required this.description,
    required this.followUp,
    required this.volunteer,
  });

  /// Empty incident for initialization
  static final empty = Incident(
    id: '',
    cat: Cat.empty,
    reportDate: DateTime.now(),
    reportedBy: MyUser.empty,
    vetVisit: false,
    description: '',
    followUp: false,
    volunteer: MyUser.empty,
  );
  Incident copyWith({
    String? id,
    Cat? cat,
    DateTime? reportDate,
    MyUser? reportedBy,
    bool? vetVisit,
    String? description,
    bool? followUp,
    MyUser? volunteer,
  }) {
    return Incident(
      id: id ?? this.id,
      cat: cat ?? this.cat,
      reportDate: reportDate ?? this.reportDate,
      reportedBy: reportedBy ?? this.reportedBy,
      vetVisit: vetVisit ?? this.vetVisit,
      description: description ?? this.description,
      followUp: followUp ?? this.followUp,
      volunteer: volunteer ?? this.volunteer,
    );
  }

  bool get isEmpty => this == Incident.empty;
  bool get isNotEmpty => this != Incident.empty;

  /// Convert `Incident` to an `IncidentEntity`
  IncidentEntity toEntity() {
    return IncidentEntity(
      id: id,
      cat: cat,
      reportDate: reportDate,
      reportedBy: reportedBy.toEntity(),
      vetVisit: vetVisit,
      description: description,
      followUp: followUp,
      volunteer: volunteer.toEntity(),
    );
  }

  static Incident fromEntity(IncidentEntity entity) {
    return Incident(
      id: entity.id,
      cat: Cat.fromEntity(entity.cat as CatEntity),
      reportDate: entity.reportDate,
      reportedBy: MyUser.fromEntity(entity.reportedBy),
      vetVisit: entity.vetVisit,
      description: entity.description,
      followUp: entity.followUp ?? false,
      volunteer: MyUser.fromEntity(entity.volunteer),
    );
  }

  @override
  String toString() {
    return '''Incident: {
      id: $id,
      cat: $cat,
      reportDate: $reportDate,
      reportedBy: $reportedBy,
      vetVisit: $vetVisit,
      description: $description,
      followUp: $followUp,
      volunteer: $volunteer
    }''';
  }

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
}
