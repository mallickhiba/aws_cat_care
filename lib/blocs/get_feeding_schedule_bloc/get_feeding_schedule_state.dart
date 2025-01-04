part of 'get_feeding_schedule_bloc.dart';

sealed class GetFeedingScheduleState extends Equatable {
  const GetFeedingScheduleState();

  @override
  List<Object> get props => [];
}

final class GetFeedingScheduleInitial extends GetFeedingScheduleState {}

final class GetFeedingScheduleFailure extends GetFeedingScheduleState {}

final class GetFeedingScheduleLoading extends GetFeedingScheduleState {}

final class GetFeedingScheduleSuccess extends GetFeedingScheduleState {
  final List<FeedingSchedule> feedingSchedules;

  const GetFeedingScheduleSuccess(this.feedingSchedules);
}
