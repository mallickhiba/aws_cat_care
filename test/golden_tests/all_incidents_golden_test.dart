import 'dart:ui';

import 'package:cat_repository/cat_repository.dart';
import 'package:cat_repository/src/models/cat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/screens/incidents/all_incidents_page.dart';
import 'package:aws_app/blocs/get_all_incidents_bloc/get_all_incidents_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockGetAllIncidentsBloc extends Mock implements GetAllIncidentsBloc {}

class MockGetCatBloc extends Mock implements GetCatBloc {}

class MockIncidentRepository extends Mock implements IncidentRepository {}

class MockCatRepository extends Mock implements CatRepository {}

void main() {
  group('AllIncidentsPage Golden Tests', () {
    final mockCat = Cat(
        catId: '1',
        catName: 'Fluffy',
        age: 2,
        color: 'White',
        campus: 'Main Campus',
        status: 'Adopted',
        isVaccinated: true,
        isHealthy: true,
        isFixed: true,
        location: 'Building A',
        description: 'A friendly and playful cat.',
        image: 'https://via.placeholder',
        sex: 'male',
        myUser: MyUser.empty);
    final mockCats = [mockCat, mockCat];
    final mockIncident = Incident(
      catId: '1',
      description: 'Incident 1',
      reportDate: DateTime.now(),
      vetVisit: true,
      followUp: false,
      reportedBy: MyUser.empty,
      id: '',
      volunteer: MyUser.empty,
    );
    testGoldens('Loading State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetAllIncidentsBloc>(
              create: (_) =>
                  MockGetAllIncidentsBloc()..add(const GetAllIncidents()),
            ),
            BlocProvider<GetCatBloc>(
              create: (_) => MockGetCatBloc(),
            ),
          ],
          child: const AllIncidentsPage(),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'all_incidents_loading');
    });

    testGoldens('Success State - Non-empty List', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetAllIncidentsBloc>(
              create: (_) => MockGetAllIncidentsBloc()
                ..emit(GetAllIncidentsSuccess([mockIncident, mockIncident])),
            ),
            BlocProvider<GetCatBloc>(
              create: (_) => MockGetCatBloc()..emit(GetCatSuccess(mockCats)),
            ),
          ],
          child: const AllIncidentsPage(),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'all_incidents_success_non_empty');
    });

    testGoldens('Success State - Empty List', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetAllIncidentsBloc>(
              create: (_) =>
                  MockGetAllIncidentsBloc()..emit(GetAllIncidentsSuccess([])),
            ),
            BlocProvider<GetCatBloc>(
              create: (_) => MockGetCatBloc(),
            ),
          ],
          child: const AllIncidentsPage(),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'all_incidents_success_empty');
    });

    testGoldens('Failure State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetAllIncidentsBloc>(
              create: (_) =>
                  MockGetAllIncidentsBloc()..emit(GetAllIncidentsFailure()),
            ),
            BlocProvider<GetCatBloc>(
              create: (_) => MockGetCatBloc(),
            ),
          ],
          child: const AllIncidentsPage(),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'all_incidents_failure');
    });
  });
}
