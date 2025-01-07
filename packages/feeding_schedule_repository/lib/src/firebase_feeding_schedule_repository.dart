//handle all methods
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeding_schedule_repository/feeding_schedule_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseFeedingScheduleRepository implements FeedingScheduleRepository {
  final feedingScheduleCollection =
      FirebaseFirestore.instance.collection('feeding_schedules');

  @override
  Future<FeedingSchedule> createFeedingSchedule(
      FeedingSchedule feedingSchedule) async {
    try {
      feedingSchedule.feedingScheduleId = const Uuid().v1();

      await feedingScheduleCollection
          .doc(feedingSchedule.feedingScheduleId)
          .set(feedingSchedule.toEntity().toDocument());

      return feedingSchedule;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<FeedingSchedule>> getFeedingSchedule() {
    try {
      return feedingScheduleCollection.get().then((value) => value.docs
          .map((e) => FeedingSchedule.fromEntity(
              FeedingScheduleEntity.fromDocument(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteFeedingSchedule(String feedingScheduleId) async {
    final feedingScheduleDoc = FirebaseFirestore.instance
        .collection('feeding_schedules')
        .doc(feedingScheduleId);
    await feedingScheduleDoc.delete();
  }

  @override
  Future<void> updateFeedingSchedule(FeedingSchedule feedingSchedule) async {
    final feedingScheduleDoc = FirebaseFirestore.instance
        .collection('feeding_schedules')
        .doc(feedingSchedule.feedingScheduleId);
    await feedingScheduleDoc.update(feedingSchedule.toEntity().toDocument());
  }
}

// feeding_schedule