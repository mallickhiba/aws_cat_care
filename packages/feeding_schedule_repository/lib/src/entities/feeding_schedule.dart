import 'package:user_repository/user_repository.dart';

class FeedingScheduleEntity {
  String feedingScheduleId;
  DateTime datetime;
  String slot;
  MyUser volunteer;
  MyUser backup;
  bool completed;

  FeedingScheduleEntity({
    required this.feedingScheduleId,
    required this.datetime,
    required this.slot,
    required this.volunteer,
    required this.backup,
    required this.completed,
  });

  Map<String, Object?> toDocument() {
    return {
      'feedingScheduleId': feedingScheduleId,
      'datetime': datetime,
      'slot': slot,
      'volunteer': volunteer.toEntity().toDocument(),
      'backup': backup.toEntity().toDocument(),
      'completed': completed,
    };
  }

  static FeedingScheduleEntity fromDocument(Map<String, dynamic> doc) {
    return FeedingScheduleEntity(
      feedingScheduleId: doc['feedingScheduleId'] as String,
      datetime: doc['datetime'] as DateTime,
      slot: doc['slot'] as String,
      volunteer: MyUser.fromEntity(MyUserEntity.fromDocument(doc['volunteer'])),
      backup: MyUser.fromEntity(MyUserEntity.fromDocument(doc['backup'])),
      completed: doc['completed'] as bool,
    );
  }

  List<Object?> get props => [
        feedingScheduleId,
        datetime,
        slot,
        volunteer,
        backup,
        completed,
      ];

  @override
  String toString() {
    return '''FeedingScheduleEntity: {
        feedingScheduleId: $feedingScheduleId,
      datetime: $datetime,
        slot: $slot,
        volunteer: $volunteer,
        backup: $backup,
        completed: $completed,
    }''';
  }
}
