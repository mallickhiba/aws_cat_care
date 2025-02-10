import 'package:aws_app/blocs/get_feeding_schedule_bloc/get_feeding_schedule_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feeding_schedule_repository/feeding_schedule_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:user_repository/user_repository.dart';

class MockFeedingScheduleRepository extends Mock
    implements FeedingScheduleRepository {}

void main() {
  group('GetFeedingScheduleBloc', () {
    late MockFeedingScheduleRepository mockFeedingScheduleRepository;
    late List<FeedingSchedule> mockFeedingSchedules;

    setUp(() {
      mockFeedingScheduleRepository = MockFeedingScheduleRepository();
      mockFeedingSchedules = [
        FeedingSchedule(
            feedingScheduleId: '',
            datetime: DateTime.now(),
            slot: '',
            volunteer: MyUser.empty,
            backup: MyUser.empty,
            completed: false)
      ];
      when(() => mockFeedingScheduleRepository.getFeedingSchedule())
          .thenAnswer((_) async => mockFeedingSchedules);
    });

    blocTest<GetFeedingScheduleBloc, GetFeedingScheduleState>(
      'emits [GetFeedingScheduleLoading, GetFeedingScheduleSuccess] when GetFeedingSchedules is added',
      build: () => GetFeedingScheduleBloc(
          feedingScheduleRepository: mockFeedingScheduleRepository),
      act: (bloc) => bloc.add(GetFeedingSchedules()),
      expect: () => [
        GetFeedingScheduleLoading(),
        GetFeedingScheduleSuccess(mockFeedingSchedules)
      ],
    );
    blocTest<GetFeedingScheduleBloc, GetFeedingScheduleState>(
        'emits loading, sucess on successful deletion',
        build: () => GetFeedingScheduleBloc(
            feedingScheduleRepository: mockFeedingScheduleRepository),
        act: (bloc) {
          bloc.add(const DeleteFeedingSchedule('1'));
        },
        expect: () => [
              GetFeedingScheduleLoading(),
              GetFeedingScheduleSuccess(mockFeedingSchedules)
            ],
        verify: (_) {
          verify(() => mockFeedingScheduleRepository.deleteFeedingSchedule('1'))
              .called(1);
          verify(() => mockFeedingScheduleRepository.getFeedingSchedule())
              .called(1);
        });
    blocTest<GetFeedingScheduleBloc, GetFeedingScheduleState>(
        'emits failure on failure to delete',
        build: () => GetFeedingScheduleBloc(
            feedingScheduleRepository: mockFeedingScheduleRepository),
        setUp: () {
          when(() => mockFeedingScheduleRepository.deleteFeedingSchedule(any()))
              .thenThrow(Exception('Deletion failed'));
        },
        act: (bloc) => bloc.add(const DeleteFeedingSchedule('1')),
        expect: () => [GetFeedingScheduleFailure()]);
  });
}
