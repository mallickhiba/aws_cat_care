import 'package:user_repository/user_repository.dart';

import '../entities/entities.dart';

class Incident {
  String id;
  String catId;
  DateTime reportDate;
  MyUser reportedBy;
  bool vetVisit;
  String description;
  bool followUp;
  MyUser volunteer;
  List<String> photos;

  Incident({
    required this.id,
    required this.catId,
    required this.reportDate,
    required this.reportedBy,
    required this.vetVisit,
    required this.description,
    required this.followUp,
    required this.volunteer,
    this.photos = const [],
  });

  static final empty = Incident(
    id: '',
    catId: '',
    reportDate: DateTime.now(),
    reportedBy: MyUser.empty,
    vetVisit: false,
    description: '',
    followUp: false,
    volunteer: MyUser.empty,
    photos: [],
  );
  Incident copyWith({
    String? id,
    String? catId,
    DateTime? reportDate,
    MyUser? reportedBy,
    bool? vetVisit,
    String? description,
    bool? followUp,
    MyUser? volunteer,
    List<String>? photos,
  }) {
    return Incident(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      reportDate: reportDate ?? this.reportDate,
      reportedBy: reportedBy ?? this.reportedBy,
      vetVisit: vetVisit ?? this.vetVisit,
      description: description ?? this.description,
      followUp: followUp ?? this.followUp,
      volunteer: volunteer ?? this.volunteer,
      photos: photos ?? this.photos,
    );
  }

  bool get isEmpty => this == Incident.empty;
  bool get isNotEmpty => this != Incident.empty;

  IncidentEntity toEntity() {
    return IncidentEntity(
      id: id,
      catId: catId,
      reportDate: reportDate,
      reportedBy: reportedBy.toEntity(),
      vetVisit: vetVisit,
      description: description,
      followUp: followUp,
      volunteer: volunteer.toEntity(),
      photos: photos,
    );
  }

  static Incident fromEntity(IncidentEntity entity) {
    return Incident(
      id: entity.id,
      catId: entity.catId,
      reportDate: entity.reportDate,
      reportedBy: MyUser.fromEntity(entity.reportedBy),
      vetVisit: entity.vetVisit,
      description: entity.description,
      followUp: entity.followUp ?? false,
      volunteer: MyUser.fromEntity(entity.volunteer),
      photos: entity.photos,
    );
  }

  @override
  String toString() {
    return '''Incident: {
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
    };
  }
}
