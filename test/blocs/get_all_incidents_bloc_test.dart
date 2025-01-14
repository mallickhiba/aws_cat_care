import 'package:aws_app/blocs/get_all_incidents_bloc/get_all_incidents_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

class MockIncident extends Mock implements Incident {}

void main() {
  group('GetAllIncidentBloc', () {
    final mockIncidentRepository = MockIncidentRepository();
    final incident = Incident(
        id: '1',
        reportDate: DateTime.now(),
        catId: '1',
        reportedBy: MyUser.empty,
        vetVisit: false,
        description: '',
        followUp: false,
        volunteer: MyUser.empty);
    final List<Incident> incidents = [incident];

    when(() => mockIncidentRepository.getAllIncidents())
        .thenAnswer((_) async => incidents);

    blocTest<GetAllIncidentsBloc, GetAllIncidentsState>(
      'handles GetAllIncidents sucessfully',
      build: () =>
          GetAllIncidentsBloc(incidentRepository: mockIncidentRepository),
      act: (bloc) => bloc.add(const GetAllIncidents()),
      expect: () => <GetAllIncidentsState>[
        GetAllIncidentsLoading(),
        GetAllIncidentsSuccess(incidents)
      ],
    );

    blocTest<GetAllIncidentsBloc, GetAllIncidentsState>(
      'handles GetAllIncidents when it fails',
      build: () =>
          GetAllIncidentsBloc(incidentRepository: mockIncidentRepository),
      setUp: () {
        when(() => mockIncidentRepository.getAllIncidents())
            .thenThrow(Exception('Failed to fetch incidents'));
      },
      act: (bloc) => bloc.add(const GetAllIncidents()),
      expect: () => <GetAllIncidentsState>[
        GetAllIncidentsLoading(),
        GetAllIncidentsFailure()
      ],
    );
  });
}
