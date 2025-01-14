import 'dart:ui';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/incidents/cat_incidents_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockGetIncidentsForCatBloc extends Mock
    implements GetIncidentsForCatBloc {}

class MockMyUserBloc extends Mock implements MyUserBloc {}

void main() {
  const catId = "cat1";
  final mockUser = MyUser(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    role: 'admin',
    picture: '',
  );
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

  group('IncidentPage Golden Tests', () {
    testGoldens('Loading State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetIncidentsForCatBloc>(
              create: (_) => MockGetIncidentsForCatBloc()
                ..emit(GetIncidentsForCatLoading()),
            ),
            BlocProvider<MyUserBloc>(
              create: (_) =>
                  MockMyUserBloc()..emit(MyUserState.success(mockUser)),
            ),
          ],
          child: const IncidentPage(catId: catId),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'incident_page_loading');
    });

    testGoldens('Success State - Non-empty List', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetIncidentsForCatBloc>(
              create: (_) => MockGetIncidentsForCatBloc()
                ..emit(GetIncidentsForCatSuccess([
                  Incident(
                    id: '1',
                    description: 'First Incident',
                    catId: catId,
                    vetVisit: false,
                    followUp: false,
                    reportedBy: mockUser,
                    volunteer: mockUser,
                    reportDate: DateTime.now(),
                  ),
                ])),
            ),
            BlocProvider<MyUserBloc>(
              create: (_) => MockMyUserBloc()
                ..emit(
                  MyUserState.success(mockUser),
                ),
            )
          ],
          child: const IncidentPage(catId: catId),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'incident_page_success_non_empty');
    });

    testGoldens('Success State - Empty List', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetIncidentsForCatBloc>(
              create: (_) => MockGetIncidentsForCatBloc()
                ..emit(const GetIncidentsForCatSuccess([])),
            ),
            BlocProvider<MyUserBloc>(
              create: (_) =>
                  MockMyUserBloc()..emit(MyUserState.success(mockUser)),
            ),
          ],
          child: const IncidentPage(catId: catId),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'incident_page_success_empty');
    });

    testGoldens('Failure State', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetIncidentsForCatBloc>(
              create: (_) => MockGetIncidentsForCatBloc()
                ..emit(const GetIncidentsForCatFailure("error")),
            ),
            BlocProvider<MyUserBloc>(
              create: (_) =>
                  MockMyUserBloc()..emit(MyUserState.success(mockUser)),
            ),
          ],
          child: const IncidentPage(catId: catId),
        ),
        surfaceSize: const Size(375, 812),
      );
      await screenMatchesGolden(tester, 'incident_page_failure');
    });

    testGoldens('Incident Details Bottom Sheet - Admin Role', (tester) async {
      await loadAppFonts();
      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<GetIncidentsForCatBloc>(
              create: (_) => MockGetIncidentsForCatBloc()
                ..emit(GetIncidentsForCatSuccess([
                  Incident(
                    id: '1',
                    description: 'First Incident',
                    catId: catId,
                    vetVisit: true,
                    followUp: true,
                    reportedBy: mockUser,
                    volunteer: mockUser,
                    reportDate: DateTime.now(),
                  ),
                ])),
            ),
            BlocProvider<MyUserBloc>(
              create: (_) =>
                  MockMyUserBloc()..emit(MyUserState.success(mockUser)),
            ),
          ],
          child: const IncidentPage(catId: catId),
        ),
        surfaceSize: const Size(375, 812),
      );

      await tester.tap(find.text('First Incident'));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'incident_details_admin');
    });
  });
}
