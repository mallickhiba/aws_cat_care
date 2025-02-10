import 'package:user_repository/user_repository.dart';
import '../entities/entities.dart';

class FeedingSchedule {
  String feedingScheduleId;
  DateTime datetime;
  String slot;
  MyUser volunteer;
  MyUser backup;
  bool completed;

  FeedingSchedule({
    required this.feedingScheduleId,
    required this.datetime,
    required this.slot,
    required this.volunteer,
    required this.backup,
    required this.completed,
  });

  static final empty = FeedingSchedule(
    feedingScheduleId: '',
    datetime: DateTime.now(),
    slot: '',
    volunteer: MyUser.empty,
    backup: MyUser.empty,
    completed: false,
  );

  FeedingSchedule copyWith({
    String? feedingScheduleId,
    DateTime? datetime,
    String? slot,
    MyUser? volunteer,
    MyUser? backup,
    bool? completed,
  }) {
    return FeedingSchedule(
      feedingScheduleId: feedingScheduleId ?? this.feedingScheduleId,
      datetime: datetime ?? this.datetime,
      slot: slot ?? this.slot,
      volunteer: volunteer ?? this.volunteer,
      backup: backup ?? this.backup,
      completed: completed ?? this.completed,
    );
  }

  bool get isEmpty => this == FeedingSchedule.empty;

  bool get isNotEmpty => this != FeedingSchedule.empty;

  FeedingScheduleEntity toEntity() {
    return FeedingScheduleEntity(
      feedingScheduleId: feedingScheduleId,
      datetime: datetime,
      slot: slot,
      volunteer: volunteer,
      backup: backup,
      completed: completed,
    );
  }

  static FeedingSchedule fromEntity(FeedingScheduleEntity entity) {
    return FeedingSchedule(
      feedingScheduleId: entity.feedingScheduleId,
      datetime: entity.datetime,
      slot: entity.slot,
      volunteer: entity.volunteer,
      backup: entity.backup,
      completed: entity.completed,
    );
  }

  @override
  String toString() {
    return '''FeedingSchedule: {
      datetime: $datetime,
      slot: $slot,
      volunteer: $volunteer,
      backup: $backup,
      completed: $completed,
    }''';
  }

  toDocument() {}

  static fromDocument(Map<String, dynamic> json) {}
}
