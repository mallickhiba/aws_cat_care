import 'package:user_repository/user_repository.dart';

class FeedingScheduleEntity {
  String feedingScheduleId;
  DateTime datetime;
  String location;
  String slot;
  MyUser volunteer;
  MyUser backup;

  FeedingScheduleEntity({
    required this.feedingScheduleId,
    required this.datetime,
    required this.location,
    required this.slot,
    required this.volunteer,
    required this.backup,
  });

  Map<String, Object?> toDocument() {
    return {
      'feedingScheduleId': feedingScheduleId,
      'datetime': datetime,
      'location': location,
      'slot': slot,
      'volunteer': volunteer.toEntity().toDocument(),
      'backup': backup.toEntity().toDocument(),
    };
  }

  static FeedingScheduleEntity fromDocument(Map<String, dynamic> doc) {
    return FeedingScheduleEntity(
        feedingScheduleId: doc['feedingScheduleId'] as String,
        datetime: doc['datetime'] as DateTime,
        location: doc['location'] as String,
        slot: doc['slot'] as String,
        volunteer:
            MyUser.fromEntity(MyUserEntity.fromDocument(doc['volunteer'])),
        backup: MyUser.fromEntity(MyUserEntity.fromDocument(doc['backup'])));
  }

  List<Object?> get props => [
        feedingScheduleId,
        datetime,
        location,
        slot,
        volunteer,
        backup,
      ];

  @override
  String toString() {
    return '''FeedingScheduleEntity: {
        feedingScheduleId: $feedingScheduleId,
      datetime: $datetime,
       location: $location
        slot: $slot,
        volunteer: $volunteer,
        backup: $backup,
    }''';
  }
}
