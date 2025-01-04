import 'package:feeding_schedule_repository/feeding_schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';

part 'get_feeding_schedule_event.dart';
part 'get_feeding_schedule_state.dart';

class GetFeedingScheduleBloc
    extends Bloc<GetFeedingScheduleEvent, GetFeedingScheduleState> {
  final FeedingScheduleRepository _feedingScheduleRepository;

  GetFeedingScheduleBloc(
      {required FeedingScheduleRepository feedingScheduleRepository})
      : _feedingScheduleRepository = feedingScheduleRepository,
        super(GetFeedingScheduleInitial()) {
    on<GetFeedingSchedules>((event, emit) async {
      emit(GetFeedingScheduleLoading());
      try {
        List<FeedingSchedule> feedingSchedules =
            await _feedingScheduleRepository.getFeedingSchedule();
        emit(GetFeedingScheduleSuccess(feedingSchedules));
      } catch (e) {
        emit(GetFeedingScheduleFailure());
      }
    });
    on<DeleteFeedingSchedule>((event, emit) async {
      try {
        await feedingScheduleRepository
            .deleteFeedingSchedule(event.feedingScheduleId);
        add(GetFeedingSchedules()); // Refresh the list after deletion
      } catch (error) {
        emit(GetFeedingScheduleFailure());
      }
    });
  }
}
