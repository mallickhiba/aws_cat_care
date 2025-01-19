import 'dart:ui';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/screens/home_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockMyUserBloc extends MockBloc<MyUserEvent, MyUserState>
    implements MyUserBloc {}

class MockGetCatBloc extends MockBloc<GetCatEvent, GetCatState>
    implements GetCatBloc {}

void main() {
  group('Golden Tests', () {
    testGoldens('Home Screen Golden Test', (tester) async {
      final mockMyUserBloc = MockMyUserBloc();
      final mockGetCatBloc = MockGetCatBloc();

      // Mock user data
      final mockUser = MyUser(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        role: 'admin',
        picture: '',
      );

      // Mock `MyUserBloc` state
      when(() => mockMyUserBloc.state)
          .thenReturn(MyUserState.success(mockUser));

      // Mock `GetCatBloc` state
      when(() => mockGetCatBloc.state).thenReturn(GetCatSuccess(const []));

      await tester.pumpWidgetBuilder(
        MultiBlocProvider(
          providers: [
            BlocProvider<MyUserBloc>(
              create: (_) => mockMyUserBloc,
            ),
            BlocProvider<GetCatBloc>(
              create: (_) => mockGetCatBloc,
            ),
          ],
          child: const HomeScreen(),
        ),
        surfaceSize: const Size(375, 812),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      await screenMatchesGolden(tester, 'home_screen');
    });
  });
}
