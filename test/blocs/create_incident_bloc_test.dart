import 'package:aws_app/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

class MockIncident extends Mock implements Incident {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockIncident());
  });

  group('CreateIncidentBloc', () {
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

    blocTest<CreateIncidentBloc, CreateIncidentState>(
      'handles CreateIncident successfully',
      build: () =>
          CreateIncidentBloc(incidentRepository: mockIncidentRepository),
      setUp: () {
        when(() => mockIncidentRepository.createIncident(incident, '1'))
            .thenAnswer((_) async => incident);
      },
      act: (bloc) => bloc.add(CreateIncident(incident, '1')),
      expect: () => <CreateIncidentState>[
        CreateIncidentLoading(),
        CreateIncidentSuccess(incident)
      ],
    );

    blocTest<CreateIncidentBloc, CreateIncidentState>(
      'handles CreateIncident when it fails',
      build: () =>
          CreateIncidentBloc(incidentRepository: mockIncidentRepository),
      setUp: () {
        when(() => mockIncidentRepository.createIncident(incident, '1'))
            .thenThrow(Exception('Failed to create incident'));
      },
      act: (bloc) => bloc.add(CreateIncident(incident, '1')),
      expect: () => <CreateIncidentState>[
        CreateIncidentLoading(),
        CreateIncidentFailure()
      ],
    );
  });
}
