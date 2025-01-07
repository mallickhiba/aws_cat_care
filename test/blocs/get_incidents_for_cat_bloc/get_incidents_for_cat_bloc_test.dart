import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:user_repository/user_repository.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

void main() {
  group('GetIncidentsForCatBloc', () {
    late MockIncidentRepository mockIncidentRepository;
    late List<Incident> mockIncidents;

    setUp(() {
      mockIncidentRepository = MockIncidentRepository();
      mockIncidents = [
        Incident(
            id: '1',
            description: '',
            catId: '1',
            reportDate: DateTime.now(),
            reportedBy: MyUser.empty,
            vetVisit: false,
            followUp: false,
            volunteer: MyUser.empty)
      ];
      when(() => mockIncidentRepository.getIncidentsForCat('1'))
          .thenAnswer((_) async => mockIncidents);
    });

    blocTest<GetIncidentsForCatBloc, GetIncidentsForCatState>(
      'emits [GetIncidentsForCatLoading, GetIncidentsForCatSuccess] when GetIncidentsForCat is added',
      build: () =>
          GetIncidentsForCatBloc(incidentRepository: mockIncidentRepository),
      act: (bloc) => bloc.add(const GetIncidentsForCat(catId: '1')),
      expect: () => [
        GetIncidentsForCatLoading(),
        GetIncidentsForCatSuccess(mockIncidents)
      ],
    );
    blocTest<GetIncidentsForCatBloc, GetIncidentsForCatState>(
      'emits states correctly when DeleteIncidentForCat is added and succeeds',
      build: () =>
          GetIncidentsForCatBloc(incidentRepository: mockIncidentRepository),
      act: (bloc) {
        when(() => mockIncidentRepository.deleteIncident('incident1'))
            .thenAnswer((_) async {});
        bloc.add(const DeleteIncidentForCat('1', '1'));
      },
      expect: () => [
        GetIncidentsForCatLoading(), // Assuming it loads after deleting for refresh
        GetIncidentsForCatSuccess(mockIncidents)
      ],
    );
  });
}
