import 'package:user_repository/user_repository.dart';
import '../entities/entities.dart';

class FeedingSchedule {
  String feedingScheduleId;
  DateTime datetime;
  String location;
  String slot;
  MyUser volunteer;
  MyUser backup;

  FeedingSchedule({
    required this.feedingScheduleId,
    required this.datetime,
    required this.location,
    required this.slot,
    required this.volunteer,
    required this.backup,
  });

  /// Empty user which represents an unauthenticated user.
  static final empty = FeedingSchedule(
    feedingScheduleId: '',
    datetime: DateTime.now(),
    location: '',
    slot: '',
    volunteer: MyUser.empty,
    backup: MyUser.empty,
  );

  /// Modify MyUser parameters
  FeedingSchedule copyWith({
    String? feedingScheduleId,
    DateTime? datetime,
    String? location,
    String? slot,
    MyUser? volunteer,
    MyUser? backup,
  }) {
    return FeedingSchedule(
      feedingScheduleId: feedingScheduleId ?? this.feedingScheduleId,
      datetime: datetime ?? this.datetime,
      location: location ?? this.location,
      slot: slot ?? this.slot,
      volunteer: volunteer ?? this.volunteer,
      backup: backup ?? this.backup,
    );
  }

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == FeedingSchedule.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != FeedingSchedule.empty;

  FeedingScheduleEntity toEntity() {
    return FeedingScheduleEntity(
      feedingScheduleId: feedingScheduleId,
      datetime: datetime,
      location: location,
      slot: slot,
      volunteer: volunteer,
      backup: backup,
    );
  }

  static FeedingSchedule fromEntity(FeedingScheduleEntity entity) {
    return FeedingSchedule(
      feedingScheduleId: entity.feedingScheduleId,
      datetime: entity.datetime,
      location: entity.location,
      slot: entity.slot,
      volunteer: entity.volunteer,
      backup: entity.backup,
    );
  }

  @override
  String toString() {
    return '''FeedingSchedule: {
      datetime: $datetime,
      location: $location
      slot: $slot,
      volunteer: $volunteer,
      backup: $backup,
    }''';
  }

  toDocument() {}

  static fromDocument(Map<String, dynamic> json) {}
}