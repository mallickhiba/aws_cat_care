part of 'get_feeding_schedule_bloc.dart';

sealed class GetFeedingScheduleEvent extends Equatable {
  const GetFeedingScheduleEvent();

  @override
  List<Object> get props => [];
}

class GetFeedingSchedules extends GetFeedingScheduleEvent {}

class DeleteFeedingSchedule extends GetFeedingScheduleEvent {
  final String feedingScheduleId;

  const DeleteFeedingSchedule(this.feedingScheduleId);
}
