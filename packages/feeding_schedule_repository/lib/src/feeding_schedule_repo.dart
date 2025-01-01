import 'models/models.dart';

abstract class FeedingScheduleRepository {
  Future<FeedingSchedule> createFeedingSchedule(
      FeedingSchedule feedingSchedule);

  Future<List<FeedingSchedule>> getFeedingSchedule();

  updateFeedingSchedule(FeedingSchedule feedingSchedule) {}

  deleteFeedingSchedule(String feedingScheduleId) {}
}
